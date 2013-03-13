class ActivitiesController < ApplicationController
  # expose(:activity) { Activity.find_published(params[:id], params[:token]) }
  expose(:cache_show) { params[:token].blank? }
  expose(:version) { Version.current }

  def show
    # @cooked_this = cooked_ids.include?(activity.id)
    @activity = Activity.includes(:ingredients).find_published(params[:id], params[:token])
    @techniques = Activity.published.techniques.last(4)
    @recipes = @activity.related_by_ingredients
    @discussion = Forum.discussions.first
    if params[:course_id]
      @course = Course.find(params[:course_id])
    end
  end

  def cooked_this
    return head :error unless params[:id].present?
    return head :ok if cooked_ids.include?(activity.id)

    @cooked_count = activity.cooked_this += 1
    if activity.save
      cooked_ids << activity.id
      render 'cooked_success', format: :js
    else
      head :error
    end
  end

  # This is the base feed that we tell feedburner about. Users should never see this.
  # See note in next method.
  def base_feed
    # this will be the name of the feed displayed on the feed reader
    @title = "ChefSteps - Free Sous Vide Cooking Course - Sous Vide Recipes - Modernist Cuisine"

    # the news items
    @activities = Activity.order("updated_at desc")

    # this will be our Feed's update timestamp
    @updated = @activities.first.updated_at unless @activities.empty?

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

  def cooked_ids
    session[:cooked_ids] ||= []
  end
end

