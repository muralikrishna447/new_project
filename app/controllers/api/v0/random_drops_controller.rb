module Api
  module V0
    class RandomDropsController < BaseController

      before_filter :ensure_authorized, only: [:show]

      def show
        if (params[:id] == @user_id_from_token.to_s) || current_user.role == 'admin'
          @random_drop = RandomDrop.query(params[:id])
          @random_drop['url'] = "https://store.#{Rails.application.config.shared_config[:chefsteps_endpoint]}/cart/#{@random_drop['variant_id']}:1?discount=#{@random_drop['discount_code']}"
          render_api_response 200, @random_drop
        else
          render_api_response 401, {message: 'Unauthorized'}
        end
      end

    end
  end
end
