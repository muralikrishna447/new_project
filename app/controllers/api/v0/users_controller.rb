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
          is_new_user = User.find_by_email(params[:user][:email]).blank?
          @user = User.facebook_connect(params[:user])
          if is_new_user
            create_new_user(@user)
          else
            render json: {status: '200 Success', token: create_token(@user)}, status: 200
          end
        else
          @user = User.new(params[:user])
          create_new_user(@user)
        end
      end

      private

      def create_new_user(user)
        if user.save
          email_list_signup(user.name, user.email, params[:source])
          render json: {status: '200 Success', token: create_token(user)}, status: 200
        else
          render json: {status: '400 Bad Request', message: 'An error occured when trying to create this user.'}, status: 400
        end
      end

    end
  end
end