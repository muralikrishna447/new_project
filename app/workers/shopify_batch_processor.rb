#puts ShopifyAPI::Base.site
#puts ShopifyAPI::Order.inspect
class ShopifyBatchProcessor
  DEFAULT_PERIOD = 100.hours

  # Run frequently on recent orders (every five minutes on last 10 of orders
  # Run less frequently on more

  def run(period = DEFAULT_PERIOD)
    updated_at_min = (Time.now - period).utc.to_s
    Rails.logger.info "Processing shopify orders since #{updated_at_min}"
    page = 1
    orders_processed = 0
    begin
      Rails.logger.info "Fetching page #{page}"
      # Our ancient version of active resource doesn't have a "where" method
      path = ShopifyAPI::Order.collection_path(:updated_at_min => updated_at_min, :limit => 100, :page => page)
      orders = ShopifyAPI::Order.find(:all, :from => path)
      orders.each do |order_data|
        order = Shopify::Order.find(order_data.id)    
        order.process!
        orders_processed += 1
      end
      break
      page += 1
      throw "Page number suspiciously high" if page > 10000
    end while orders.length != 0
    Librato::Metrics.submit 'shopify.batch-processor.success' => 1
    Rails.logger.info "Batch processor complete - [#{orders_processed}] orders processed."
  end
end
