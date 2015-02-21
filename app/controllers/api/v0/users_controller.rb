module Api
  module V0
    class UsersController < BaseController
      before_filter :ensure_authorized, except: [:create]

      def index
        per = params[:per] ? params[:per] : 12
        @users = User.page(params[:page]).per(per)
        render json: @users
      end

      def create
        params[:source] ||= "api_standard"
        if params[:user][:provider] && params[:user][:provider] == 'facebook'
          @user = User.facebook_connect(params[:user])
        else
          @user = User.new(params[:user])
        end
        if @user.save
          email_list_signup(@user.name, @user.email, params[:source])
          render json: {status: '200 Success', token: create_token(@user)}, status: 200
        else
          render json: {status: '400 Bad Request', message: 'An error occured when trying to create this user.'}, status: 400
        end
      end

    end
  end
end