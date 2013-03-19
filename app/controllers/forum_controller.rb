class ForumController < ApplicationController
  
  def discussion
    @discussion = Forum.discussions.first
    render json: @discussion
  end

end