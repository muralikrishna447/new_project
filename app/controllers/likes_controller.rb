class LikesController < ApplicationController
  before_filter :authenticate_user!, only: [:create]

  def create
    @like = Like.new(params[:like])
    @like.user_id = current_user.id
    if @like.save
      track_event @like
    end
    redirect_to request.referrer
  end

end