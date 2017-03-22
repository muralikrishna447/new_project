module Api
  module V0
    class WebhooksController < BaseController
      def shopify
        # TODO - consider adding a shared secret in the webhook url we register with shopify
        if %w(order_paid order_created).include?(params[:type])
          order_id = params[:id].to_i
          if order_id == 0
            return render_api_response 400, {'message' => "Invalid order id [#{order_id.inspect}]"}
          end
        end

        case params[:type]
        when 'order_paid'
          logger.info "Processing order_paid webhook for order #{order_id}"
          Resque.enqueue(ShopifyOrderProcessor, order_id)
          render_api_response 200
        when 'order_created'
          logger.info "Processing order_created webhook for order #{order_id}"
          Resque.enqueue(PremiumOrderProcessor, order_id)
          Resque.enqueue(Fraud::PaymentProcessor, order_id)
          render_api_response 200
        else
          render_api_response 400, {'message' => "Unexpected type [#{params[:type].inspect}]"}
        end
      end
    end
  end
end
