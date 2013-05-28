class ActivitiesController < ApplicationController
  # expose(:activity) { Activity.find_published(params[:id], params[:token]) }
  expose(:cache_show) { params[:token].blank? }
  expose(:version) { Version.current }

  before_filter :find_activity, only: :show

  DUMMY_NEW_ACTIVITY_NAME = "DUMMY NEW ACTIVITY"

  def find_activity
    @activity = Activity.find params[:id]

    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the activity_path, and we should do
    # a 301 redirect that uses the current friendly id.
    if request.path != activity_path(@activity) && params[:course_id].nil?
      # Wish I could just do params: params but that creates ugly urls
      redir_params = {}
      redir_params[:version] = params[:version] if defined? params[:version]
      redir_params[:minimal] = params[:minimal] if defined? params[:minimal]
      redir_params[:token] = params[:token] if defined? params[:token]
      redir_params[:scaling] = params[:scaling] if defined? params[:scaling]
      redirect_to activity_path(@activity, redir_params), :status => :moved_permanently
    end
  end


  before_filter :require_admin, only: [:new, :update_as_json]
  def require_admin
    unless admin_user_signed_in?
      flash[:error] = "You must be logged in as an administrator to do this"
      redirect_to new_admin_user_session_path
    end
  end

  def show

    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token], admin_user_signed_in?)
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end

    respond_to do |format|
      format.html do

        @techniques = Activity.published.techniques.includes(:steps).last(6)
        @recipes = Activity.published.recipes.includes(:steps).last(6)

        if params[:course_id]
          @course = Course.find(params[:course_id])
        end

        if @activity.has_quizzes?
          render template: 'activities/quizzes'
        end

        @minimal = false
        if params[:minimal]
          @minimal = true
        end

        @user_activity = UserActivity.new

        # cookies.delete(:viewed_activities)
        @viewed_activities = cookies[:viewed_activities].nil? ? [] : JSON.parse(cookies[:viewed_activities])
        @viewed_activities << [@activity.id, DateTime.now]
        cookies[:viewed_activities] = @viewed_activities.to_json

        if ! @course
          @include_edit_toolbar = true
        end

        # If this is a crawler, render a basic HTML page for SEO that doesn't depend on Angular
        if params.has_key?(:'_escaped_fragment_')
          render template: 'activities/static_html'
        end
      end
   end
  end

  def new
    @activity = Activity.new()
    @activity.title = DUMMY_NEW_ACTIVITY_NAME
    @activity.description = ""
    # Have to save because we edit in our show view, and that view really needs an id
    @activity.save!
    @activity.title = ""
    @include_edit_toolbar = true
    render 'show'
  end

  def fork
    old_activity = Activity.find(params[:id])
    @activity = old_activity.deep_copy
    @activity.title = "#{current_user ? current_user.name : current_admin_user.email.split('@')[0]}'s Version Of #{old_activity.title}"
    @activity.save!
    render :json => {redirect_to: activity_path(@activity, {start_in_edit: true})}
  end

  def get_as_json

    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token], admin_user_signed_in?)
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end

    # Can't save with this, but want it to be blank in show view
    @activity.title = "" if @activity.title == DUMMY_NEW_ACTIVITY_NAME

    # For the relations, sending only the fields that are visible in the UI; makes it a lot
    # clearer what to do on update.
    respond_to do |format|
      format.json {
        render :json => @activity.to_json(
          include: {
              tags: {},
              equipment: {
                only: :optional,
                include: {
                  equipment: {
                    only: [:id, :title, :product_url]
                  }
                }
              },
              ingredients: {
                only: [:note, :display_quantity, :quantity, :unit],
                include: {
                  ingredient: {
                    only: [:id, :title, :product_url, :for_sale, :sub_activity_id]
                  }
                }
              }
          }
        )
      }
    end
  end

  def update_as_json
    if params[:fork]
      # Can't seem to get custom verb & URL to work in angular, so tacking it onto this one
      fork()
    else
      @activity = Activity.find(params[:id])
      respond_to do |format|
        format.json do

          old_slug = @activity.slug

          @activity.store_revision do
            @activity.last_edited_by = current_admin_user
            @activity.update_equipment_json(params[:activity].delete(:equipment))
            @activity.update_ingredients_json(params[:activity].delete(:ingredients))
            # Why on earth is tags the only thing not root wrapped??
            tags = params.delete(:tags)
            @activity.tag_list = tags.map { |t| t[:name]} if tags
            @activity.attributes = params[:activity]
            @activity.save!
          end

          # This would be better handled by history state / routing in frontend, but ok for now
          if @activity.slug != old_slug
            render :json => {redirect_to: activity_path}
          else
            head :no_content
          end
        end
      end
    end
  end

  def get_all_tags
    result = ActsAsTaggableOn::Tag.where('name iLIKE ?', '%' + params[:q] + '%').all
    respond_to do |format|
      format.json {
        render :json => result.to_json()
      }
    end
  end

  # This is the base feed that we tell feedburner about. Users should never see this.
  # See note in next method.
  def base_feed
    # this will be the name of the feed displayed on the feed reader
    @title = "ChefSteps - Free Sous Vide Cooking Course - Sous Vide Recipes - Modernist Cuisine"

    # the news items
    @activities = Activity.published.order("updated_at desc")

    # this will be our Feed's update timestamp
    @updated = @activities.published.first.updated_at unless @activities.empty?

    respond_to do |format|
      format.atom { render 'feed',  :layout => false }
    end
  end

  # See http://support.google.com/feedburner/answer/78464?hl=en under Alternative Traffic Redirection Method
  # If someone asks for chefsteps.com/feed we will redirect them. This gives us a path to safety
  # if feedburner goes away someday. Everyone will have bookmarked chefsteps.com/feed in their reader
  # and we can just change this one redirect below to go direct to base_feed.
  def feedburner_feed
    redirect_to "http://feeds.feedburner.com/ChefSteps"
  end

end

