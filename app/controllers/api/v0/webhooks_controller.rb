module Api
  module V0
    class WebhooksController < BaseController
      def shopify
        # TODO - consider adding a shared secret in the webhook url we register with shopify
        if params[:type] == 'order'
          order_id = params[:id].to_i
          if order_id == 0
            return render_api_response 400, {'message' => "Invalid order id [#{order_id.inspect}]"}
          end
          logger.info "Processing webhook for order #{order_id}"

          Resque.enqueue(ShopifyOrderProcessor, order_id)
          render_api_response 200
        else
          render_api_response 400, {'message' => "Unexpected type [#{params[:type].inspect}]"}
        end
      end
    end
  end
end
