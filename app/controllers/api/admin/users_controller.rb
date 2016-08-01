module Api
  module Admin
    class UsersController < ApiAdminController

      before_filter :load_user, only: [:actor_addresses, :circulators, :show]

      # /api/admin/users/:id
      def show
        render_api_response 200, @user
      end

      # /api/admin/users?email=user@email.com
      def index
        email = params[:email]
        if email
          @users = User.where(email: email)
        end
        render json: @users
      end

      # /api/admin/users/:id/actor_addresses
      def actor_addresses
        render json: @user.actor_addresses
      end

      # /api/admin/users/:id/circulators
      def circulators
        render json: @user.circulators, each_serializer: Api::Admin::CirculatorSerializer
      end

      private

      def load_user
        @user = User.find(params[:id])
      end

    end
  end
end
