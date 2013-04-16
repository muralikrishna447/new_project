class ActivitiesController < ApplicationController
  # expose(:activity) { Activity.find_published(params[:id], params[:token]) }
  expose(:cache_show) { params[:token].blank? }
  expose(:version) { Version.current }

  #before_filter :find_activity

  def find_activity
    @activity = Activity.find params[:id]

    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the activity_path, and we should do
    # a 301 redirect that uses the current friendly id.
    if request.path != activity_path(@activity)
      # Wish I could just do params: params but that creates ugly urls
      redir_params = {}
      redir_params[:version] = params[:version] if defined? params[:version]
      redir_params[:minimal] = params[:minimal] if defined? params[:minimal]
      redir_params[:token] = params[:token] if defined? params[:token]
      redirect_to activity_path(@activity, redir_params), :status => :moved_permanently
    end
  end

  def show
    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token])

    if params[:version] && params[:version].to_i <= @activity.last_revision().revision
        @activity = @activity.restore_revision(params[:version])
    end

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

  def get_edit_partial
    @activity = Activity.find(params[:id])
    respond_to do |format|
      format.js { render 'get_edit_partial', locals: {partial_name: params[:partialname]}}
    end
  end

  def update_edit_partial
    @activity = Activity.find(params[:id])
    @activity.update_attributes(params[:activity])
    @activity.save!
    respond_to do |format|
      format.js { render 'get_show_partial', locals: {partial_name: params[:partialname]}}
    end
  end

end

