module Api
  module V0
    module Shopping
      class CustomerOrdersController < BaseController

        before_filter :ensure_authorized_or_anonymous

        def show
          puts "CURRENT API USER DUDE: #{current_api_user.inspect}"
          begin
            @order = ShopifyAPI::Order.find(params[:id])
            if current_api_user && (@order.email == current_api_user.email || current_api_user.role == 'admin')
              response = {
                id: @order.id,
                shipping_address: @order.shipping_address
              }
              render_api_response 200, response
            else
              render_api_response(403, {message: 'Unauthorized'})
            end
          rescue
            render_api_response(404, {message: 'Order not found'})
          end
        end

        def create
          order_id = params[:order_id]
          shipping_address = params[:order][:shipping_address]
          puts "CUSTOMER ORDER: #{order_id}"
          puts "CUSTOMER ORDER shipping_address: #{shipping_address}"
          # TODO Actually create the record
          render_api_response 200, {message: "Successfully created shipping address for Order Id #{order_id}", order_id: order_id, shipping_address: shipping_address}
        end

      end
    end
  end
end
