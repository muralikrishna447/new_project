class HomeController < ApplicationController

  def index
    @courses = Course.published.order('updated_at desc').last(3)
    if current_user
      @latest = Activity.published.chefsteps_generated.really_include_in_gallery.order('published_at desc').first(6)
      @projects = Assembly.published.projects.last(3)
      # @followings_stream = Kaminari::paginate_array(current_user.followings_stream).page(params[:page]).per(6)
      # @stream = current_user.received_stream.take(4)
    else
      @heroes = Setting.featured_activities
      @recipes = Activity.published.chefsteps_generated.recipes.includes(:steps).last(6) - @heroes
      @techniques = Activity.published.chefsteps_generated.techniques.includes(:steps).last(6) - @heroes
      @sciences = Activity.published.chefsteps_generated.sciences.includes(:steps).last(6) - @heroes
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
