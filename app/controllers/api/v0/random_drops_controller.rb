module Api
  module V0
    class RandomDropsController < BaseController

      before_filter :ensure_authorized, only: [:show]

      def show
        if params[:id] == @user_id_from_token.to_s
          @random_drop = RandomDrop.get(params[:id])
          render_api_response 200, @random_drop
        else
          render_api_response 401, {message: 'Unauthorized'}
        end
      end

    end
  end
end
