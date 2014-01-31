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

    # If this activity should only be shown in paid courses, and the user isn't an admin, send
    # them to the course landing page. Also allow:
    # (1) Googlebot so it can index the page
    # (2) Referred from google (for first click free: https://support.google.com/webmasters/answer/74536?hl=en)
    # (3) Brombone bot so it can make the snapshot for _escaped_segment_
    referer = http_referer_uri
    is_google = request.env['HTTP_USER_AGENT'].downcase.index('googlebot/') || (referer && referer.host.index('google'))
    is_brombone = request.headers["X-Crawl-Request"] == 'brombone'
    if (! current_admin?) && (! is_google) && (! is_brombone)
      if @activity.show_only_in_course
        redirect_to class_path(@activity.containing_course), :status => :moved_permanently
      end

      if @activity.containing_course && current_user && current_user.enrolled?(@activity.containing_course)
        redirect_to class_activity_path(@activity.containing_course, @activity)
      end

      if @activity.assemblies.first.assembly_type == 'Project'
        redirect_to assembly_activity_path(@activity.assemblies.first, @activity)
      end
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

  def show

    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token], can?(:update, @activity))
    @upload = Upload.new
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end

    respond_to do |format|
      format.html do
        @random_recipes = Activity.published.chefsteps_generated.include_in_feeds.recipes.includes(:steps).order("RANDOM()").last(6)
        @popular_recipes = Activity.published.chefsteps_generated.include_in_feeds.recipes.includes(:steps).order("RANDOM()").first(6)

        # New school class
        containing_class = @activity.containing_course
        if containing_class && containing_class.published?
          case containing_class.assembly_type
          when 'Course'
            path = view_context.link_to containing_class.title, landing_class_path(containing_class)
          when 'Project'
            path = view_context.link_to containing_class.title, project_path(containing_class)
          when 'Recipe Development'
            path = view_context.link_to containing_class.title, recipe_development_path(containing_class)
          end
          flash.now[:notice] = "This is part of the #{path} #{containing_class.assembly_type.to_s}."
        end
        track_event @activity

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
    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
      @activity = @activity.restore_revision(params[:version])
    end
    track_event(@activity, 'show')

    # For the relations, sending only the fields that are visible in the UI; makes it a lot
    # clearer what to do on update.
    respond_to do |format|
      format.json {
        unless @activity.containing_course && current_user && current_user.enrollments.where(enrollable_id: @activity.containing_course.id, enrollable_type: @activity.containing_course.class).first.try(:free_trial_expired?) && @activity.containing_course.price > 0
          render :json => @activity.to_json
        else
          if mixpanel_anonymous_id
            mixpanel.people.append(current_user.email, {'Free Trial Expired' => @activity.containing_course.slug})
            mixpanel.track(mixpanel_anonymous_id, 'Free Trial Expired', {slug: @activity.containing_course.slug, length: current_user.class_enrollment(@activity.containing_course).free_trial_length})
          end
          render :json => {error: "No longer have access", path: landing_class_url(@activity.containing_course)}, status: :forbidden
        end
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

end
