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
        @user = User.new(params[:user])
        if @user.save!
          render json: {status: '200 Success', token: create_token(@user)}, status: 200
        else
          render json: {status: '400 Bad Request'}, status: 400
        end
      end

    end
  end
end