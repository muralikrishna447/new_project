module Api
  module V0
    class ProfilesController < BaseController

      def show
        @user = User.find(params[:id])
        render json: @user, serializer: Api::ProfileSerializer, scope: current_admin?
      end

      def likes
        per = params[:per] ? params[:per] : 12
        @user = User.find(params[:id])
        @likes = @user.likes.scoped_by_type('Activity').page(params[:page]).per(per).map &:likeable
        render json: @likes, each_serializer: Api::ActivityIndexSerializer
      end

      def classes
        per = params[:per] ? params[:per] : 12
        @user = User.find(params[:id])
        @enrollments = @user.enrollments.page(params[:page]).per(per).map &:enrollable
        render json: @enrollments, each_serializer: Api::AssemblyIndexSerializer
      end

      def photos
        per = params[:per] ? params[:per] : 12
        @user = User.find(params[:id])
        @photos = @user.uploads.page(params[:page]).per(per)
        render json: @photos, each_serializer: Api::PhotoSerializer
      end

      def recipes
        per = params[:per] ? params[:per] : 12
        @user = User.find(params[:id])
        @recipes = @user.created_activities.page(params[:page]).per(per)
        render json: @recipes, each_serializer: Api::ActivityIndexSerializer
      end

    end
  end
end
