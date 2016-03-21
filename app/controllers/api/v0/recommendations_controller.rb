module Api
  module V0
    class RecommendationsController < BaseController

      def index
        tags = params[:tags]
        @results = Activity.chefsteps_generated.include_in_gallery.published.tagged_with(tags, any: true).order('published_at desc').page(params[:page]).per(8)
        render json: @results, each_serializer: Api::ActivityIndexSerializer
      end

    end
  end
end