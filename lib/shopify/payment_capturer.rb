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
        transaction = build_capture_transaction(order)
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

      def build_capture_transaction(order)
        # For orders that are not partially paid, the Shopify API will capture
        # the correct amount without explicitly specifying it.
        transaction = ShopifyAPI::Transaction.new(kind: 'capture')
        transaction.prefix_options[:order_id] = order.id
        return transaction unless order.financial_status == 'partially_paid'

        # For orders that are partially paid (e.g., because a gift card was used
        # for a part of the total amount), the Shopify API will try to capture
        # the full amount without taking into account the part that was already paid.
        # The call to capture payment fails because it the capture amount is greater
        # than what was authorized. So here we have to look up the amount that was
        # authorized (which is another Shopify API call) and explicitly set that
        # amount on the capture transaction.
        Rails.logger.info "PaymentProcessor order with id #{order.id} is partially_paid, " \
                          'finding authorization amount to capture'
        auth_transacations = order.transactions.select do |transaction|
          successful_cc_auth?(transaction)
        end
        if auth_transacations.empty?
          raise "No credit card authorization found for order with id #{order.id}"
        end

        amount = auth_transacations.inject(0.0) { |sum, t| sum + t.amount.to_f }
        Rails.logger.info "PaymentProcessor will capture authorization amount #{amount} " \
                          "for order with id #{order.id}"
        transaction.amount = amount
        transaction
      end

      def successful_cc_auth?(transaction)
        return false unless transaction.kind == 'authorization'
        return false if transaction.gateway == 'gift_card'
        return false unless transaction.status == 'success'
        true
      end
    end
  end
end
