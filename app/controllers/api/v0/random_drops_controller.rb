module Api
  module V0
    class RandomDropsController < BaseController

      before_filter :ensure_authorized, only: [:show]

      def show
        @random_drop = {
          user_id: 1,
          discount_code: 'RANDOMDISCOUNT',
          variant_id: 'VARIANTID'
        }
        render_api_response 200, @random_drop
      end

    end
  end
end
