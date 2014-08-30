module Api
  module V0
    class ActivitiesController < ApplicationController
      
      has_scope :sort do |controller, scope, value|
        case value
          when "oldest"
            scope.by_published_at("asc")
          when "newest"
            scope.by_published_at("desc")
          when "popular"
            scope.popular
          else
            # Relevance is the default sort for pg_search so don't need to do anything
            scope
        end
      end

      has_scope :published, default: true,  type: :boolean

      def index
        @activities = apply_scopes(Activity).uniq().page(params[:page]).per(12)
        render json: @activities, each_serializer: Api::ActivityIndexSerializer
      end

      def show
        @activity = Activity.find(params[:id])
        render json: @activity, serializer: Api::ActivitySerializer
      end
    end
  end
end