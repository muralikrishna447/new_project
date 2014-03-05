class TokensController < ApplicationController
  def verify
    @user = User.where(id: params[:id]).where(authentication_token: params[:auth_token])
    if @user.any?
      render nothing: true, status: 200
    else
      render nothing: true, status: 401
    end
  end
end