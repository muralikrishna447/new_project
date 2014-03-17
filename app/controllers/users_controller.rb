class UsersController < ApplicationController
  # before_filter :authenticate_user!
  def show
    @user = User.find(params[:id])
    render json: @user.to_json(only: [:id, :name], methods: :avatar_url)
  end

  def index
    ids = params[:ids]
    @users = User.where(id: ids)
    render json: @users.to_json(only: [:id, :name], methods: :avatar_url)
  end

end