require 'resque/plugins/lock'

class BatchPremiumOrderProcessor
  extend Resque::Plugins::Lock

  # Stripe auth expires after 7 days, no point going back further.
  DEFAULT_PERIOD = 8.days

  @queue = 'BatchPremiumOrderProcessor'

  def self.lock(*args)
    'BatchPremiumOrderProcessor'
  end

  def self.perform(period = DEFAULT_PERIOD)
    Rails.logger.info("BatchPremiumOrderProcessor starting perform with period #{period}")
    processed_at_min = (Time.now - period).utc.to_s
    params = {
      processed_at_min: processed_at_min,
      status: 'open'
    }
    orders_processed = 0
    Shopify::Utils.search_orders_with_each(params) do |order|
      PremiumOrderProcessor.perform(order.id)
      orders_processed += 1
    end

    Rails.logger.info("BatchPremiumOrderProcessor processed #{orders_processed} orders")

    report_metrics(orders_processed)
  end

  def self.report_metrics(orders_processed)
    Librato.increment 'fraud.batch-premium-order-processor.success', sporadic: true
    Librato.increment 'fraud.batch-premium-order-processor.orders.count', by: orders_processed, sporadic: true
    Librato.tracker.flush
  end
end
