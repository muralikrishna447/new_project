module Fulfillment
  class PaymentStatusFilter
    # An order is fulfillable if payment has been captured.
    # Note that payment must be captured to subsequently refund an order
    # (partially or fully), so the allowable states are as follows.
    FULFILLABLE_STATES = %w(paid partially_refunded refunded)

    def self.payment_captured?(order)
      if FULFILLABLE_STATES.include?(order.financial_status)
        Rails.logger.info("PaymentStatusFilter order with id #{order.id} is " \
                          "fulfillable because financial_status is #{order.financial_status}")
        return true
      end

      Rails.logger.info("PaymentStatusFilter order with id #{order.id} is " \
                        "not fulfillable because financial_status is #{order.financial_status}")
      false
    end
  end
end
