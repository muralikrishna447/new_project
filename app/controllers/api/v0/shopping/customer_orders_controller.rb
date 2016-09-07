module Api
  module V0
    module Shopping
      class CustomerOrdersController < BaseController

        before_filter :ensure_authorized_or_anonymous
        before_filter :load_user

        def show
          begin
            @order = ShopifyAPI::Order.find(params[:id])
            if @order.email == @user.email
              response = {
                id: @order.id,
                shipping_address: @order.shipping_address
              }
              render_api_response 200, response
            else
              raise 'Unauthorized'
            end
          rescue
            render_api_response(404, {message: 'Order not found'})
          end
        end

        private

        def load_user
          if @user_id_from_token
            @user = User.find @user_id_from_token
          else
            @user = nil
          end
        end

      end
    end
  end
end
