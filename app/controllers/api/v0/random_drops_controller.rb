module Api
  module V0
    class RandomDropsController < BaseController

      before_filter :ensure_authorized, only: [:show]

      def show
        @random_drop = RandomDrop.get(params[:id])
        render_api_response 200, @random_drop
      end

    end
  end
end
