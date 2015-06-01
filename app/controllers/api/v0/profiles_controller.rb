module Api
  module V0
    class ProfilesController < BaseController

      def show
        @user = User.find(params[:id])
        render json: @user, serializer: Api::ProfileSerializer
      end
      
    end
  end
end
