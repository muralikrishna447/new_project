class FollowershipsController < ApplicationController
  before_filter :authenticate_user!

  def index

  end

  def update
    @user = User.find(params[:id])
    if current_user.follows?(@user)
      current_user.unfollow(@user)
      message = "You are no longer following #{@user.name}"
    else
      current_user.follow(@user)
      message = "You are now following #{@user.name}"
    end
    respond_to do |format|
      format.html { redirect_to request.referer, notice: message }
      format.json { render json: @user }
    end
  end

  def follow_multiple
    @users = User.where(id: params[:ids])
    @users.each do |user|
      current_user.follow(user) unless current_user.follows?(user)
    end
    render(json: @users)
  end
end