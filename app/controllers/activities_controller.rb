class ActivitiesController < ApplicationController
  # expose(:activity) { Activity.find_published(params[:id], params[:token]) }
  expose(:cache_show) { params[:token].blank? }
  expose(:version) { Version.current }

  before_filter :maybe_redirect_activity, only: :show

  def maybe_redirect_activity
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
  rescue
    # Not a problem
  end


  before_filter :require_admin, only: [:new, :update_as_json]
  def require_admin
    unless can? :update, Activity
      flash[:error] = "You must be logged in as an administrator to do this"
      redirect_to new_user_session_path
    end
  end

  def show

    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token], can?(:update, @activity))
    @upload = Upload.new
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
          return
        else
          if @activity.courses.any? && @activity.courses.first.published?
            flash.now[:notice] = "This is part of the free #{view_context.link_to @activity.courses.first.title, @activity.courses.first} course."
          end
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

        if ! @course
          @include_edit_toolbar = true
        end

        @source_activity = @activity.source_activity

        # If this is a crawler, render a basic HTML page for SEO that doesn't depend on Angular
        if params.has_key?(:'_escaped_fragment_')
          render template: 'activities/static_html'
          return
        end
      end
   end
  end

  def new
    @activity = Activity.new()
    @activity.title = ""
    @activity.description = ""
    @activity.title = ""
    @activity.creator = current_user.admin? ? nil : current_user
    @include_edit_toolbar = true
    @activity.save({validate: false})
    track_event(@activity, 'create') unless current_user.admin?
    redirect_to activity_path(@activity, {start_in_edit: true})
  end

  def fork
    old_activity = Activity.find(params[:id])
    @activity = old_activity.deep_copy
    @activity.title = "#{current_user.name}'s Version Of #{old_activity.title}"
    @activity.creator = current_user.admin? ? nil : current_user
    @activity.save!
    track_event(@activity, 'create') unless current_user.admin?
    render :json => {redirect_to: activity_path(@activity, {start_in_edit: true})}
  end

  def get_as_json

    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token], can?(:update, Activity))
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end

    # For the relations, sending only the fields that are visible in the UI; makes it a lot
    # clearer what to do on update.
    respond_to do |format|
      format.json {
        render :json => @activity.to_json
      }
    end
  end

  def notify_start_edit
    # Done this way to avoid touching the updated_at field as that is used to know whether to replace the model on
    # the angular side.
    # http://stackoverflow.com/questions/11766037/update-attribute-without-altering-the-updated-at-field
    Activity.where(id: params[:id]).update_all(currently_editing_user: current_user)
    head :no_content
  end

  def notify_end_edit
    Activity.where(id: params[:id]).update_all(currently_editing_user: nil)
    head :no_content
  end


  def update_as_json
    # This will get handled in notify_end_edit; don't want to touch here
    params[:activity].delete(:currently_editing_user)
    params[:activity].delete(:creator)

    if params[:fork]
      # Can't seem to get custom verb & URL to work in angular, so tacking it onto this one
      fork()
    else

      @activity = Activity.find(params[:id])

      respond_to do |format|
        format.json do

          old_slug = @activity.slug

          @activity.create_or_update_as_ingredient

          @activity.store_revision do

            begin
              @activity.last_edited_by = current_user
              equip = params[:activity].delete(:equipment)
              ingredients = params[:activity].delete(:ingredients)
              steps = params.delete(:steps)
              # Why on earth are tags and steps not root wrapped but equipment and ingredients are?
              # I'm not sure where this happens, but maybe using the angular restful resources plugin would help.
              tags = params.delete(:tags)
              @activity.tag_list = tags.map { |t| t[:name]} if tags
              @activity.attributes = params[:activity]
              @activity.save!

              @activity.update_equipment_json(equip)
              @activity.update_ingredients_json(ingredients)
              @activity.update_steps_json(steps)

              # This would be better handled by history state / routing in frontend, but ok for now
              if @activity.slug != old_slug
                render json: {redirect_to: activity_path(@activity)}
              else
                head :no_content
              end

            rescue Exception => e
              messages = [] || @activity.errors.full_messages
              messages.push(e.message)
              render json: { errors: messages}, status: 422
            end
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

