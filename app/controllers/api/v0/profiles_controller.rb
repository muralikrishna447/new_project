module Api
  module V0
    class ProfilesController < BaseController

      def show
        @user = User.find(params[:id])
        # if current_admin?
        #   render json: @user, meta: {email: @user.email}, serializer: Api::ProfileSerializer
        # else
        #   render json: @user, serializer: Api::ProfileSerializer
        # end
        render json: @user, serializer: Api::ProfileSerializer, scope: current_admin?
      end

      def likes
        @likes = Like.where(user_id: params[:id]).scoped_by_type('Activity').map &:likeable
        render json: @likes, each_serializer: Api::ActivityIndexSerializer
      end

      def classes
        @enrollments = Enrollment.where(user_id: params[:id]).map &:enrollable
        render json: @enrollments, each_serializer: Api::AssemblyIndexSerializer
      end

      def photos
        @photos = Upload.where(user_id: params[:id])
        render json: @photos, each_serializer: Api::PhotoSerializer
      end

    end
  end
end
