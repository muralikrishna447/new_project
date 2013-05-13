class ActivitiesController < ApplicationController
  # expose(:activity) { Activity.find_published(params[:id], params[:token]) }
  expose(:cache_show) { params[:token].blank? }
  expose(:version) { Version.current }

  before_filter :find_activity, only: :show

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
      redirect_to activity_path(@activity, redir_params), :status => :moved_permanently
    end
  end


  before_filter :require_admin, only: [:update]
  def require_admin
    unless admin_user_signed_in?
      flash[:error] = "You must be logged in as an administrator to do this"
      redirect_to new_admin_user_session_path
    end
  end

  def show
    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token])
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end

    respond_to do |format|
      format.html do
        @techniques = Activity.published.techniques.includes(:steps).last(6)
        @recipes = Activity.published.recipes.includes(:steps).last(6)

        if params[:course_id]
          @course = Course.find(params[:course_id])
          @current_module = @course.current_module(@activity)
          @current_inclusion = @course.inclusions.where(activity_id: @activity.id).first
          @prev_activity = @course.prev_published_activity(@activity)
          @next_activity = @course.next_published_activity(@activity)
          if @prev_activity
            @prev_module = @course.current_module(@prev_activity)
          end
          if @activity.assignments.any?
            @upload = Upload.new
            session[:return_to] = request.fullpath
          end
          render 'course_activity'
          track_event @current_inclusion
        else
          track_event @activity
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

        # If this is a crawler, render a basic HTML page for SEO that doesn't depend on Angular
        if params.has_key?(:'_escaped_fragment_')
          render template: 'activities/static_html'
        end
      end
   end
  end

  def get_as_json
    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token])
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end

    # For the relations, sending only the fields that are visible in the UI; makes it a lot
    # clearer what to do on update.
    respond_to do |format|
      format.json {
        render :json => @activity.to_json(
          include: {
              equipment: {
                only: :optional,
                include: {
                  equipment: {
                    only: [:title, :id, :product_url]
                  }
                }
              }
          }
        )
      }
    end
  end

  def update_as_json
    @activity = Activity.find(params[:id])
    respond_to do |format|
      format.json do

        @activity.store_revision do
          @activity.last_edited_by = current_admin_user
          @activity.update_equipment_json(params[:activity].delete(:equipment))
          @activity.attributes = params[:activity]
          @activity.save!
        end

        head :no_content
      end
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

