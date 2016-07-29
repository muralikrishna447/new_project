module Api
  module Admin
    class UsersController < ApiAdminController

      before_filter :load_user, only: [:actor_addresses, :circulators]

      def actor_addresses
        render json: @user.actor_addresses
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
