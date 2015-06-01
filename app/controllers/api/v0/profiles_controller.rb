module Api
  module V0
    class ProfilesController < BaseController

      def show
        @user = User.find(params[:id])
        render json: @user, serializer: Api::ProfileSerializer
      end

      def likes
        @likes = Like.where(user_id: params[:id]).scoped_by_type('Activity').map &:likeable
        render json: @likes, each_serializer: Api::ActivityIndexSerializer
      end

    end
  end
end
