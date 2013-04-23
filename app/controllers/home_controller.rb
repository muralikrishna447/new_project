class HomeController < ApplicationController

  def index
    @heroes = Setting.featured_activities
    @recipes = Activity.published.recipes.includes(:steps).last(6) - @heroes
    @techniques = Activity.published.techniques.includes(:steps).last(6) - @heroes
    @sciences = Activity.published.sciences.includes(:steps).last(6) - @heroes
    if cookies[:returning_visitor]
      # @discussion = Forum.discussions.first
      # @status = Twitter.status_embed
    elsif params[:new_visitor]     
      @courses = Course.published
      render 'new_visitor_homepage'
    end
  end

  def about
    @chris = Copy.find_by_location('creator-chris')
    @grant = Copy.find_by_location('creator-grant')
    @ryan = Copy.find_by_location('creator-ryan')
  end
end
