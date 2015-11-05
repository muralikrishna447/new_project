class StripeWebhookProcessor
  @queue = :stripe_webhook_processor
  def self.perform(stripe_event_id)
    stripe_event = StripeEvent.find(stripe_event_id)
    return if stripe_event.processed

    # For the reports
    case stripe_event.event_type
    when 'charge.succeeded'
    when 'charge.refunded'
    when 'charge.dispute.created'
    when 'charge.dispute.closed'
    end

    # For the future orders
    case stripe_event.event_type
    when 'order.created'
      order_created(stripe_event)
    when 'order.payment_failed'
      order_failed(stripe_event)
    when 'order.payment_succeeded'
      order_charged(stripe_event)
    when 'order.updated'
      # Unused
    end

    # For the ecommerce products
    case stripe_event.event_type
    when 'sku.created'
      sku_handler(stripe_event)
    when 'sku.updated'
      sku_handler(stripe_event)
    when 'product.created'
      product_handler(stripe_event)
    when 'product.updated'
      product_handler(stripe_event)
    end

    stripe_event.processed = true
    stripe_event.save
  end


  def order_charged(stripe_event)
    # Send to quickbooks
  end

  def order_failed(stripe_event)
    # Handle failure
  end

  def product_handler(stripe_event)
    Rails.cache.delete("stripe_products")
  end

  def sku_handler(stripe_event)
    Rails.cache.delete("stripe_products")
  end
end
