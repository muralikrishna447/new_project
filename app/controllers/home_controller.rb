class HomeController < ApplicationController

  def index
    @heroes = Setting.featured_activities
    @recipes = Activity.published.recipes.includes(:steps).last(6) - @heroes
    @techniques = Activity.published.techniques.includes(:steps).last(6) - @heroes
    @sciences = Activity.published.sciences.includes(:steps).last(6) - @heroes
    @courses = Course.published.last(3)
    # cookies.delete(:returning_visitor)
    @returning_visitor = cookies[:returning_visitor]
    @new_visitor = params[:new_visitor] || !@returning_visitor
    # @discussion = Forum.discussions.first
    #@status = Twitter.status_embed
    @user = User.new
  end

  def about
    @chris = Copy.find_by_location('creator-chris')
    @grant = Copy.find_by_location('creator-grant')
    @ryan = Copy.find_by_location('creator-ryan')
    t = %w[hanstwite@gmail.com ben@chefsteps.com lorraine@chefsteps.com kristina@chefsteps.com tim.salazar@gmail.com hueezer@gmail.com michaelnatkin@gmail.com edward@chefsteps.com nicholasgav@hotmail.com]
    @team = User.where(email: t)
    f = %w[chris@chefsteps.com desunaito@gmail.com glcrilly@hotmail.com]
    @founders = User.where(email: f)
  end
end
