class RecommendationsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    @recommendations = Recommendation.activities_for(current_user,6)
    render :json => @recommendations.to_json(only: [:id, :title, :image_id, :featured_image_id, :difficulty, :published_at, :slug, :premium], :include => [:steps, :creator], methods: [:gallery_path])
  end

end