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

  before_filter :require_admin, only: [:get_edit_partial, :update_edit_partial, :revert_to_version]
  def require_admin
    unless admin_user_signed_in?
      flash[:error] = "You must be logged in as an administrator to do this"
      redirect_to new_admin_user_session_path
    end
  end

  def show
    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token])

    respond_to do |format|
      format.html do
        if params[:version] && params[:version].to_i <= @activity.last_revision().revision
          @activity = @activity.restore_revision(params[:version])
        end

        @live_public_version = (@activity.last_revision().revision + 1) rescue 1

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
      end

      format.json {  render :json => @activity }

    end
  end

  def update
    respond_to do |format|
      format.json { respond_with Activity.update(params[:id], params[:activity]) }
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

  # Return a form for editing some part of an activity
  def get_edit_partial
    @activity = Activity.find(params[:id])
    respond_to do |format|
      format.js { render 'get_edit_partial', locals: {partial_name: params[:partial_name], edit_id: params[:edit_id]}}
    end
  end

  # Submit a form updating some part of an activity; record it in the revision database
  def update_edit_partial
    @activity = Activity.find(params[:id])
    @activity.attributes=(params[:activity])
    if @activity.changed?
      @activity.store_revision do
        @activity.last_edited_by = current_admin_user
        @activity.save!
      end
    end
    @partial_name = params[:partial_name]
    @edit_id = params[:edit_id]
    @last_edit_version = (@activity.last_revision().revision + 1) rescue 1
    respond_to do |format|
      format.js { render 'get_show_partial'}
    end
  end

  # Get the non-edit show view for part of an activity; used when we cancel an edit from get_edit_partial
  def get_show_partial
    @activity = Activity.find(params[:id])
    @partial_name = params[:partial_name]
    @edit_id = params[:edit_id]
    respond_to do |format|
      format.js { render 'get_show_partial'}
    end
  end

  # Back out of (one or more) committed edits
  def revert_to_version
    @activity = Activity.find(params[:id])
    @activity.restore_revision!(params[:version])
    puts  "Version #{params[:version]} has been restored and is the new version #{@activity.last_revision().revision + 1}"
    redirect_to activity_path(@activity)
  end
end

