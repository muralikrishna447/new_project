class PremiumOrderProcessor
  include Shopify::PaymentCapturer

  @queue = 'PremiumOrderProcessor'

  def self.perform(order_id)
    Rails.logger.info("PremiumOrderProcessor starting perform for order with id #{order_id}")
    api_order = Shopify::Utils.order_by_id(order_id)

    # See if order has any premium line items, return if not.
    premium_items = api_order.line_items.select { |item| item.sku == Shopify::Order::PREMIUM_SKU }
    if premium_items.empty?
      Rails.logger.info("PremiumOrderProcessor order with id #{order_id} has no premium " \
                        'line item, not processing it')
      return
    else
      Rails.logger.info("PremiumOrderProcessor order with id #{order_id} has a premium " \
                        'line item, will process it')
    end

    order = Shopify::Order.new(api_order)

    # Capture payment if the order contains only premium.
    # Otherwise the fraud payment processor will handle it.
    if Shopify::Utils.contains_only_premium?(api_order)
      capture_only_premium(order)
    else
      Rails.logger.info("PremiumOrderProcessor order with id #{order_id} has more than " \
                        'just premium line items, not capturing payment')
    end

    fulfill_premium_items(order, premium_items)

    Librato.tracker.flush
    Rails.logger.info "PremiumOrderProcessor finished perform on order with id #{order_id}"
  end

  def self.capture_only_premium(order)
    if capturable?(order.api_order)
      Rails.logger.info("PremiumOrderProcessor order with id #{order.api_order.id} contains " \
                        'only premium line items, capturing payment')
      capture_payment(order.api_order)
      # We only send analytics if the order is premium-only and therefore
      # we're completing the entire order. Otherwise, the general shopify
      # order processor will handle it.
      order.send_analytics
      Librato.increment 'shopify.premium-order-processor.capture.count', sporadic: true
    else
      Rails.logger.info("PremiumOrderProcessor order with id #{order.api_order.id} contains " \
                        'only premium line items, payment was already captured')
    end
  end

  def self.fulfill_premium_items(order, items)
    fulfilled = false
    items.each do |item|
      fulfilled = true if fulfill_premium_item(order, item)
    end
    order.sync_user if fulfilled
  end

  def self.fulfill_premium_item(order, item)
    unless fulfillable_line_item?(item)
      Rails.logger.info "PremiumOrderProcessor premium line item with id #{item.id} " \
                        "for order with id #{order.api_order.id} is not fulfillable, skipping"
      return false
    end

    if !order.gift_order? && item.quantity > 1
      raise 'Order contains more than one non-gift premium.'
    end

    Rails.logger.info("PremiumOrderProcessor fulfilling premium line item with id #{item.id} " \
                      "for order with id #{order.api_order.id}")
    order.fulfill_premium(item, true)

    initial_fulfillment_latency = Time.now - Time.parse(order.api_order.created_at)
    Rails.logger.info "Initial fulfillment latency [#{initial_fulfillment_latency}]"
    Librato.timing 'shopify.premium-order-processor.fulfillment.latency', initial_fulfillment_latency
    Librato.increment 'shopify.premium-order-processor.fulfillment.count', sporadic: true
    true
  end

  def self.fulfillable_line_item?(item)
    if item.fulfillment_status == 'fulfilled'
      Rails.logger.info "PremiumOrderProcessor line item with id #{item.id} is not " \
                        "fulfillable because fulfillment_status is #{item.fulfillment_status}"
      return false
    end
    if item.fulfillable_quantity < 1
      Rails.logger.info "PremiumOrderProcessor line item with id #{item.id} is not " \
                        "fulfillable because fulfillable_quantity is #{item.fulfillable_quantity}"
      return false
    end
    true
  end
end
