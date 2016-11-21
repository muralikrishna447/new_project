module Api
  module V0
    module Shopping
      class CustomerOrdersController < BaseController

        before_filter :ensure_authorized, only: [:show, :update_address]

        def show
          begin
            @order = ShopifyAPI::Order.find(params[:id])
            customer_multipass_identifier = @order.customer.multipass_identifier
            current_api_user_id = current_api_user.id.to_s
            current_api_user_role = current_api_user.role
            shipping_address_updatable = shipping_address_updatable(@order)
            if current_api_user && (customer_multipass_identifier == current_api_user_id || current_api_user_role == 'admin')
              response = {
                id: @order.id,
                fulfillment_status: @order.fulfillment_status,
                shipping_address: @order.shipping_address,
                shipping_address_updatable: shipping_address_updatable[:updatable],
                update_message: shipping_address_updatable[:update_message]
              }
              render_api_response 200, response
            else
              render_api_response(401, {message: 'Unauthorized'})
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

              @shipping_address = ShippingAddress.new(params[:order][:shipping_address])
              if @shipping_address.valid?
                @shipping_address.save_record(order_id,customer_multipass_identifier)
                render_api_response 200, {message: "Successfully created shipping address for Order Id #{order_id}", order_id: order_id, shipping_address: @shipping_address}
              else
                error_messages = @shipping_address.errors.map{|attribute,message| "#{attribute} #{message}"}
                render_api_response(400, {message: 'Invalid Address', errors: error_messages})
              end

            else
              render_api_response(403, {message: 'Unauthorized'})
            end
          rescue => e
            Rails.logger.error "Update Address failed with error : #{e}, order_id: #{order_id}, shipping_address: #{@shipping_address}"
            if e.message == "Couldn't find User without an ID"
              render_api_response(403, {message: 'Unauthorized'})
            elsif e.message == "Error saving ShippingAddress"
              render_api_response(500, {message: e.message})
            else
              render_api_response(404, {message: 'Order not found'})
            end
          end

        end

        def confirm_address
          order_id = params[:id]
          begin
            order_id = params[:id]
            @order = ShopifyAPI::Order.find(order_id)
            ShippingAddress.confirm(order_id)
          rescue => e
            Rails.logger.error "Confirm Address failed with error : #{e}, order_id: #{order_id}"
            render_api_response(500, {message: 'Error confirming ShippingAddress'})
          end
          render_api_response 200, {message: "Successfully confirmed address for Order Id #{order_id}", order_id: order_id}
        end

        private

        def shipping_address_updatable(order)
          fulfillment_statuses = order.fulfillments.map{|f| f.status}
          success_fulfillment_status = fulfillment_statuses.select { |status| status == 'success' }

          if fulfillment_statuses.include?('open') || fulfillment_statuses.include?('pending') # Not updatable if any fulfillments are open or pending
            updatable = false
            update_message = 'One or more items in your order are being prepared for shipping.'
          elsif fulfillment_statuses.length == success_fulfillment_status.length # Not updatable if all status equal success
            updatable = false
            update_message = 'All of the items in this order have been shipped.'
          else
            updatable = true
          end

          {
            updatable: updatable,
            update_message: update_message
          }
        end

      end
    end
  end
end
