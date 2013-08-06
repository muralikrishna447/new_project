class HomeController < ApplicationController

  def index
    if current_user
      @latest = Activity.published.chefsteps_generated.include_in_gallery.last(6)
      # @followings_stream = Kaminari::paginate_array(current_user.followings_stream).page(params[:page]).per(6)
      # @stream = current_user.received_stream.take(4)
    else
      @heroes = Setting.featured_activities
      @recipes = Activity.published.chefsteps_generated.recipes.includes(:steps).last(6) - @heroes
      @techniques = Activity.published.chefsteps_generated.techniques.includes(:steps).last(6) - @heroes
      @sciences = Activity.published.chefsteps_generated.sciences.includes(:steps).last(6) - @heroes
      @courses = Course.published.last(3)
      # cookies.delete(:returning_visitor)
      @returning_visitor = cookies[:returning_visitor]
      @new_visitor = params[:new_visitor] || !@returning_visitor
      # @discussion = Forum.discussions.first
      #@status = Twitter.status_embed
      @user = User.new
    end
  end

  def about
    @chris = Copy.find_by_location('creator-chris')
    @grant = Copy.find_by_location('creator-grant')
    @ryan = Copy.find_by_location('creator-ryan')
    t = %w[hans@chefsteps.com ben@chefsteps.com lorraine@chefsteps.com kristina@chefsteps.com tim.salazar@gmail.com hueezer@gmail.com michaelnatkin@gmail.com edward@chefsteps.com nick@chefsteps.com]
    @team = User.where(email: t)
    f = %w[chris@chefsteps.com desunaito@gmail.com grant@chefsteps.com]
    @founders = User.where(email: f)
  end
end
