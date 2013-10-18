class FollowershipsController < ApplicationController
  before_filter :authenticate_user!

  def update
    @user = User.find(params[:id])
    if current_user.follows?(@user)
      current_user.unfollow(@user)
      message = "You are no longer following #{@user.name}"
    else
      current_user.follow(@user)
      message = "You are now following #{@user.name}"
    end
    redirect_to request.referer, notice: message
  end
end