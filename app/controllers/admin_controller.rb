class AdminController < ApplicationController

  def become
    return unless current_user && current_user.admin?
    sign_in(:user, User.find(params[:id]))
    redirect_to root_url # or user_root_url
  end
end