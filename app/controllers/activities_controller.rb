class ActivitiesController < ApplicationController
  # expose(:activity) { Activity.find_published(params[:id], params[:token]) }
  expose(:cache_show) { params[:token].blank? }
  expose(:version) { Version.current }

  def show
    @activity = Activity.includes([:ingredients, :steps, :equipment]).find_published(params[:id], params[:token])
    @techniques = Activity.published.techniques.includes(:steps).last(6)
    @recipes = Activity.published.recipes.includes(:steps).last(6)
    if params[:course_id]
      @course = Course.find(params[:course_id])
    end

    if @activity.has_quizzes?
      render template: 'activities/quizzes'
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

end

