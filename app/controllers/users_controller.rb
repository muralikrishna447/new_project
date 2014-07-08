class UsersController < ApplicationController
  # before_filter :authenticate_user!
  def show
    @user = User.find(params[:id])
    user_json = @user.to_json(only: [:id, :name], methods: :avatar_url)
    encrypted = ChefstepsBloom.encrypt(user_json)
    render text: encrypted
  end

  def get_user
    @user = User.find(params[:userId])
    user_json = {data: {id: @user.id.to_s, name: @user.name, avatarUrl: @user.avatar_url}}.to_json
    render text: user_json
  end

  # Bloom will also be using this endpoint
  def index
    if params[:ids]
      ids = params[:ids].split(',')
      @users = User.where(id: [ids])
    elsif params[:emails]
      emails = params[:emails].split(',')
      @users = User.where(email: [emails])
    end
    render json: @users.to_json(only: [:id, :name, :slug], methods: :avatar_url)
  end

  # For Bloom Dashboard
  def cs
    @admins = User.where(role: 'admin')
    render json: @admins.to_json(only: [:id, :email])
  end

end