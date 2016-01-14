class ActivitiesController < ApplicationController

  instrument_action :show, :get_as_json

  # expose(:activity) { Activity.find_published(params[:id], params[:token]) }
  expose(:cache_show) { params[:token].blank? }
  expose(:version) { Version.current }

  before_filter :maybe_redirect_activity, only: :show

  after_filter :track_iphone_app_activity

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
      redir_params[:scrollto] = params[:scrollto] if defined? params[:scrollto]
      redirect_to activity_path(@activity, redir_params), :status => :moved_permanently
    end

  rescue
    # Not a problem
  end

  before_filter :require_login, only: [:new, :fork, :update_as_json]
  def require_login
    unless current_user
      flash[:error] = "You must be logged in to do this"
      redirect_to new_user_session_path
    end
  end

  # This is absurd, should be part of the activity serializer, but that is used in different
  # cases and we need to untangle what info should be passed into what view and then set up a way
  #
  def add_extra_json_info
    @activity[:used_in] = @activity.used_in_activities.published
    @activity[:forks] = @activity.published_variations
    @activity[:upload_count] = @activity.uploads.count

    # Hide secret circulator machine code field unless there is a special param in the request or requester is admin
    unless params[:param_info] == "a9a77bd9f" || current_admin?
      @activity.steps.each do |s|
        s[:extra] = nil
      end
    end

  end

  def show
    if params[:start_in_edit]
      unless can?(:update, @activity)
        redirect_to activity_path(@activity)
      end
    end
    @show_app_add = true
    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token], can?(:update, @activity))
    add_extra_json_info
    @upload = Upload.new
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end

    @activity_type_title = @activity.activity_type.first
    @activity_type_title = "Sous Vide Recipe" if @activity.activity_type.include?('Recipe') && @activity.tag_list.include?('sous vide')

    respond_to do |format|
      format.html do

        # New school class
        containing_class = @activity.containing_course
        if containing_class && containing_class.published?
          case containing_class.assembly_type
          when 'Course'
            path = view_context.link_to containing_class.title, landing_class_path(containing_class), {'no-nell-popup' => true, onclick: "mixpanel.track('Clicked Class from Activity', {'class' : '#{containing_class.title}', 'activity': '#{@activity.title}'});"}
          when 'Project'
            path = view_context.link_to containing_class.title, project_path(containing_class), {'no-nell-popup' => true, onclick: "mixpanel.track('Clicked Class from Activity', {'class' : '#{containing_class.title}', 'activity': '#{@activity.title}'});"}
          when 'Recipe Development'
            path = view_context.link_to containing_class.title, recipe_development_path(containing_class), {'no-nell-popup' => true, onclick: "mixpanel.track('Clicked Class from Activity', {'class' : '#{containing_class.title}', 'activity': '#{@activity.title}'});"}
          end
          container_name = containing_class.assembly_type.to_s
          container_name = "Class" if container_name == "Course"
          container_name = "Project" if container_name == "Project"
          @container_name = container_name
          @container_path = path
          # flash.now[:notice] = "This is part of the #{path} #{container_name}."
        end

        @minimal = false
        if params[:minimal]
          @minimal = true
        end

        @user_activity = UserActivity.new

        if current_user && cookies[:viewed_activities]
          cookies.delete(:viewed_activities)
        else
          @viewed_activities = cookies[:viewed_activities].blank? ? [] : JSON.parse(cookies[:viewed_activities])
          @viewed_activities << [@activity.id, DateTime.now]
          if @viewed_activities.length > 3
            @viewed_activities.shift
          end
          cookies[:viewed_activities] = @viewed_activities.to_json
        end

        if ! @course
          @include_edit_toolbar = true
        end

        @source_activity = @activity.source_activity
      end
    end
  end

  def new
    @activity = Activity.new()
    @activity.title = ""
    @activity.description = ""
    @activity.title = ""
    @activity.creator = current_user unless current_admin?
    @activity.activity_type << 'Recipe'
    @include_edit_toolbar = true
    @activity.save({validate: false})
    track_event(@activity, 'create') unless current_admin?
    redirect_to activity_path(@activity, {start_in_edit: true})
  end

  def fork
    old_activity = Activity.find(params[:id])
    @activity = old_activity.deep_copy
    @activity.title = "#{current_user.name}'s Version Of #{old_activity.title}"
    @activity.creator = current_user unless current_admin?
    @activity.save!
    track_event(@activity, 'create') unless current_admin?
    render :json => {redirect_to: activity_path(@activity, {start_in_edit: true})}
  end

  def get_as_json

    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token], can?(:update, Activity))
    add_extra_json_info
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end

    t1 = Time.new
    activity_json = @activity.to_json
    t2 = Time.new
    Librato.timing 'activitiescontroller.get_as_json.render', (t2-t1)*1000
    render :json => activity_json
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

      # KHK: Debugging double-escaped ampersand issue
      logger.info(
        "Updating activity #{@activity.id} with title " \
        "[#{@activity.title}] by user #{current_user.email}"
      )

      # unless current_user && (current_user.role == 'admin' || @activity.creator == current_user)
      unless can?(:update, @activity)
        render nothing: true, status: 401 and return
      end
      respond_to do |format|
        format.json do

          old_slug = @activity.slug

          @activity.create_or_update_as_ingredient

          @activity.store_revision do

            begin
              @activity.last_edited_by = current_user
              @activity.bypass_sanitization = (current_user && current_user.role == "admin")
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
              @activity.update_steps(steps)

              # This would be better handled by history state / routing in frontend, but ok for now
              if @activity.slug != old_slug
                render json: {redirect_to: activity_path(@activity)}
              else
                head :no_content
              end

              # KHK: Debugging double-escaped ampersand issue
              logger.info(
                "After updating, activity #{@activity.id} has title [#{@activity.title}]" \
                " and bypass_sanitization was #{@activity.bypass_sanitization}"
              )

            rescue Exception => e
              puts "--------- EXCEPTION -----------"
              puts $@

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
    result = ActsAsTaggableOn::Tag.where('name iLIKE ?', '%' + (params[:q] || '') + '%').all
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
    @title = "ChefSteps - Cook Smarter"

    # the news items
    @activities = Activity.published.by_published_at('desc').chefsteps_generated.include_in_feeds.limit(40)

    # this will be our Feed's update timestamp
    @updated = @activities.published.first.published_at unless @activities.empty?

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

  private
  def track_iphone_app_activity
    if from_ios_app?
      mixpanel.track(mixpanel_anonymous_id, '[iOS App] Activty Viewed', {slug: @activity.slug, title: @activity.title, context: "iOS App"})
    end
  end

end
