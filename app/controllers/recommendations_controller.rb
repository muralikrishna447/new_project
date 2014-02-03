class RecommendationsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    @recommendations = Recommendation.activities_for(current_user)
    render :json => @recommendations.to_json
  end

end