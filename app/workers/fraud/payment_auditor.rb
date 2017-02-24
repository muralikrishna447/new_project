module Fraud
  module PaymentAuditor
    @queue = 'PaymentAuditor'

    ORDER_EXEMPT_TAG = 'payment-audit-exempt'

    def self.perform
      Rails.logger.info "PaymentAuditor starting perform"

      params = {
        status: 'any',
        financial_status: 'unpaid'
      }
      max_age_days = 0
      unpaid_orders = 0
      Shopify::Utils.search_orders_with_each(params) do |order|
        next unless auditable?(order)

        order_age_days = (Time.now - Time.parse(order.processed_at)) / 60 / 60 / 24
        Rails.logger.info("PaymentAuditor order with id #{order.id} has age #{order_age_days} days")
        Librato.measure 'fraud.payment-auditor.orders.unpaid.age', order_age_days

        max_age_days = order_age_days if order_age_days > max_age_days
        unpaid_orders += 1
      end

      Rails.logger.info "PaymentAuditor found #{unpaid_orders} unpaid orders " \
                        "with max age #{max_age_days} days"
      Librato.increment 'fraud.payment-auditor.success', sporadic: true
      Librato.tracker.flush
    end

    def self.auditable?(order)
      return false if order.cancelled_at
      # There are some very old orders in prod where payment was not captured for
      # the full amount as a way of refunding or discounting the order. This should
      # never happen on new orders but we need a way to skip over the old ones.
      return false if Shopify::Utils.order_tags(order).include?(ORDER_EXEMPT_TAG)
      true
    end
  end
end
