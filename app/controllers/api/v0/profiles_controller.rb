module Api
  module V0
    class ProfilesController < BaseController

      def show
        @user = User.find(params[:id])
        render json: @user, serializer: Api::ProfileSerializer, scope: current_admin?
      end

      def likes
        @user = User.find(params[:id])
        @likes = @user.likes.scoped_by_type('Activity').map &:likeable
        render json: @likes, each_serializer: Api::ActivityIndexSerializer
      end

      def classes
        @user = User.find(params[:id])
        @enrollments = @user.enrollments.map &:enrollable
        render json: @enrollments, each_serializer: Api::AssemblyIndexSerializer
      end

      def photos
        @user = User.find(params[:id])
        @photos = @user.uploads
        render json: @photos, each_serializer: Api::PhotoSerializer
      end

    end
  end
end
