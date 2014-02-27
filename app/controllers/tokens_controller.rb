class TokensController < ApplicationController
  before_filter :authenticate_user!
  def verify
    @user = User.find(params[:id])
    if @user && @user.authentication_token == params[:auth_token]
      render text: 'success', status: 200
    else
      render text: 'unauthorized', status: 401
    end
  end
end