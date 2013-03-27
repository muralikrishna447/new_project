class HomeController < ApplicationController

  def index
    @recipes = Activity.published.recipes.includes(:steps).order('created_at DESC').first(6)
    @techniques = Activity.published.techniques.includes(:steps).order('created_at DESC').first(6)
    @sciences = Activity.published.sciences.includes(:steps).order('created_at DESC').first(6)
    @heroes = Setting.featured_activities

    # @discussion = Forum.discussions.first
    @status = Twitter.status_embed
  end

  def about
    @chris = Copy.find_by_location('creator-chris')
    @grant = Copy.find_by_location('creator-grant')
    @ryan = Copy.find_by_location('creator-ryan')
  end
end
