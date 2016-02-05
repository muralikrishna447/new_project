class ShopifyOrderProcessor
  @queue = :shopify_order_processor

  def self.perform(order_id)
    Rails.logger.info "Processing shopify order [#{order_id}]"
    begin
      shopify_order = Shopify::Order.find(order_id)
    rescue ActiveResource::ResourceNotFound
      msg = "Shopify order[#{order_id}] not found."
      Rails.logger.error msg
      raise msg
    end
    shopify_order.process!
    Rails.logger.info "Finished processing shopify order [#{order_id}]"
  end
end
