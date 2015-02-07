module Api
  module V0
    class UsersController < BaseController
      before_filter :ensure_authorized
      
      def index
        per = params[:per] ? params[:per] : 12
        @users = User.page(params[:page]).per(per)
        render json: @users
      end
    end
  end
end