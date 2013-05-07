class HomeController < ApplicationController

  def index
    @heroes = Setting.featured_activities
    @recipes = Activity.published.recipes.includes(:steps).last(6) - @heroes
    @techniques = Activity.published.techniques.includes(:steps).last(6) - @heroes
    @sciences = Activity.published.sciences.includes(:steps).last(6) - @heroes
    @courses = Course.published.last(2)
    # cookies.delete(:returning_visitor)
    @returning_visitor = cookies[:returning_visitor]
    @new_visitor = params[:new_visitor] || !@returning_visitor
    # @cta_message = ab_test('homepage_cta', 'Join The Community!', 'Become a Better Cook!')
    
    # @discussion = Forum.discussions.first
    #@status = Twitter.status_embed
  end

  def about
    @chris = Copy.find_by_location('creator-chris')
    @grant = Copy.find_by_location('creator-grant')
    @ryan = Copy.find_by_location('creator-ryan')
  end
end
