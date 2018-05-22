module Fulfillment
  class FulfillmentAuditor
    def self.perform
      Rails.logger.info 'FulfillmentAuditor starting perform'

      metrics = []
      shipping_errors = 0
      Shopify::Utils.search_orders_with_each(status: 'open') do |order|
        next unless (Shopify::Utils.order_tags(order) & Fulfillment::FILTERED_TAGS).empty?
        next unless Fulfillment::PaymentStatusFilter.payment_captured?(order)
        next unless Fulfillment::FedexShippingAddressValidator.valid?(order)

        # Orders that FBA can't ship will have this tag.
        shipping_errors += 1 if Shopify::Utils.order_tags(order).include?('shipping-error')

        order.line_items.each do |item|
          metric = process_line_item(order, item)
          metrics << metric if metric
        end
      end
      Librato.measure 'fulfillment.auditor.shipping-error.count', shipping_errors
      Librato.increment 'fulfillment.auditor.success', sporadic: true
      Librato.tracker.flush

      metrics
    end

    def self.process_line_item(order, item)
      if Fulfillment::ROSTI_FULFILLABLE_SKUS.include?(item.sku)
        fulfiller = 'rosti'
      elsif Fulfillment::FBA_FULFILLABLE_SKUS.include?(item.sku)
        fulfiller = 'amazon'
      else
        return
      end

      fulfillment = fulfillment_for_item(order, item)
      if fulfillment.nil?
        return if item.fulfillable_quantity < 1 # Item was refunded
        submission_status = 'unsubmitted'
        # Old orders that had a filtered tag and it was removed or went to
        # manual fraud review before being paid will skew the max age here
        # to the point where it may actually not be very useful to alert on.
        age_days = (Time.now - Time.parse(order.processed_at)) / 60 / 60 / 24
      elsif fulfillment.status == 'open'
        submission_status = 'submitted'
        age_days = (Time.now - Time.parse(fulfillment.created_at)) / 60 / 60 / 24
      else
        return
      end

      metric = "fulfillment.auditor.#{fulfiller}.#{submission_status}.age"
      Librato.measure metric, age_days
      [metric, order.id, age_days]
    end

    private

    # Looks up the fulfillment for a line item, or nil if non exists
    def self.fulfillment_for_item(order, item)
      order.fulfillments.select { |f| !f.line_items.select { |li| li.id == item.id }.empty? }.first
    end
  end
end
