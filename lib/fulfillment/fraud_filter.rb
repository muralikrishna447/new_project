module Fulfillment
  module FraudFilter
    APPROVED_TAG = 'fraud-check-approved'

    def self.fraud_suspected?(order)
      if Shopify::Utils.order_tags(order).include?(APPROVED_TAG)
        Rails.logger.info("FraudFilter including order with id #{order.id} because it has approved tag")
        return false
      end

      Rails.logger.debug("FraudFilter fetching risks for order with id #{order.id}")
      risks = ShopifyAPI::OrderRisk.find(:all, params: { order_id: order.id })
      shopify_suspects_fraud = false
      risks.each do |risk|
        if risk.recommendation == 'investigate' || risk.recommendation == 'cancel'
          shopify_suspects_fraud = true
          break
        end
      end

      if shopify_suspects_fraud
        Rails.logger.warn("FraudFilter filtering order with id #{order.id} due to Shopify risk level")
        return true
      end

      false
    end
  end
end
