module Api
  module Admin
    class UsersController < ApiAdminController

      before_filter :load_user, only: [:show, :circulators]

      def show
        render json: @user
      end

      def circulators
        render json: @user.circulators
      end

      private

      def load_user
        @user = User.find(params[:id])
      end

    end
  end
end
