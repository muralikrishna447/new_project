module Shopify
  module PaymentCapturer

    # Payment is capturable if we've only done an auth. Orders may be
    # partially paid if a gift card was used for only part of an order,
    # but we still need to capture the remainder of the funds.
    CAPTURABLE_FINANCIAL_STATES = %w(authorized partially_paid)

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def capturable?(order)
        if order.cancelled_at
          Rails.logger.info("PaymentProcessor order with id #{order.id} is cancelled, " \
                            'payment not capturable')
          return false
        end

        if CAPTURABLE_FINANCIAL_STATES.include?(order.financial_status)
          Rails.logger.info("PaymentProcessor order with id #{order.id} financial_status " \
                            "is #{order.financial_status}, payment is capturable")
          return true
        else
          Rails.logger.info("PaymentProcessor order with id #{order.id} financial_status " \
                            "is #{order.financial_status}, payment is not capturable")
          return false
        end
      end

      def capture_payment(order)
        Rails.logger.info("PaymentProcessor capturing payment for order with id #{order.id}")
        transaction = ShopifyAPI::Transaction.new(kind: 'capture')
        transaction.prefix_options[:order_id] = order.id
        begin
          Shopify::Utils.send_assert_true(transaction, :save)
        rescue => e
          # Re-check order status on the off chance that something or someone
          # updated the order since we last read it. If it's still capturable,
          # payment capture failed for some other reason so we re-raise.
          order = Shopify::Utils.order_by_id(order.id)
          if capturable?(order)
            Rails.logger.error "Payment capture failed for order with id #{order.id}"
            raise e
          else
            Rails.logger.warn "Tried to capture payment for order with id #{order.id}, " \
                              'but it was already captured.'
          end
        end
      end
    end
  end
end
