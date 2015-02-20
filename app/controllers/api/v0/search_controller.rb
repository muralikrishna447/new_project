module Api
  module V0
    class SearchController < BaseController

      def index
        @results = Activity.published.search_all(params[:query]).page(params[:page]).per(12)
        render json: @results, each_serializer: Api::ActivityIndexSerializer
      end

    end
  end
end