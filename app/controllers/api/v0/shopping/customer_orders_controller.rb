module Api
  module V0
    module Shopping
      class CustomerOrdersController < BaseController

        before_filter :ensure_authorized_or_anonymous, only: [:show, :update_address]

        def show
          begin
            @order = ShopifyAPI::Order.find(params[:id])
            customer_multipass_identifier = @order.customer.multipass_identifier
            current_api_user_id = current_api_user.id.to_s
            current_api_user_role = current_api_user.role
            if current_api_user && (customer_multipass_identifier == current_api_user_id || current_api_user_role == 'admin')
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

        def update_address
          begin
            order_id = params[:id]
            @order = ShopifyAPI::Order.find(order_id)
            customer_multipass_identifier = @order.customer.multipass_identifier
            current_api_user_id = current_api_user.id.to_s
            current_api_user_role = current_api_user.role
            if customer_multipass_identifier == current_api_user_id || current_api_user_role == 'admin'

              shipping_address = params[:order][:shipping_address]
              puts "CUSTOMER ORDER: #{order_id}"
              puts "CUSTOMER ORDER shipping_address: #{shipping_address}"
              # TODO Actually create the record
              render_api_response 200, {message: "Successfully created shipping address for Order Id #{order_id}", order_id: order_id, shipping_address: shipping_address}
            else
              render_api_response(403, {message: 'Unauthorized'})
            end
          rescue => e

            if e.message == "Couldn't find User without an ID"
              render_api_response(403, {message: 'Unauthorized'})
            else
              render_api_response(404, {message: 'Order not found'})
            end
          end

        end

        def confirm_address
          order_id = params[:id]
          puts "CUSTOMER ORDER: #{order_id}"
          # TODO Actually create the record
          render_api_response 200, {message: "Successfully confirmed address for Order Id #{order_id}", order_id: order_id}
        end

      end
    end
  end
end
