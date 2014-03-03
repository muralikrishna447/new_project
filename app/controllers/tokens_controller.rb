class TokensController < ApplicationController
  def verify
    # @user = User.find_by_id(params[:id]).select(:authentication_token)
    @user = User.where(id: params[:id]).where(authentication_token: params[:auth_token])
    if @user.any?
      render text: 'success', status: 200
    else
      render text: 'unauthorized', status: 401
    end
  end
end