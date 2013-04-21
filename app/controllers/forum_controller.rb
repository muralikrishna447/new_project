class ForumController < ApplicationController
  
  caches_action :discussion, :expires_in => 10.minutes

  def discussion
    @discussion = Forum.discussions.first
    render json: @discussion
  end

end