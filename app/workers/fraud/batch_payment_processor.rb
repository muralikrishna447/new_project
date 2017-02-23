require 'resque/plugins/lock'
require 'retriable'

module Fraud
  class BatchPaymentProcessor
    extend Resque::Plugins::Lock

    # Stripe auth expires after 7 days, no point going back further.
    DEFAULT_PERIOD = 8.days

    @queue = 'BatchPaymentProcessor'

    # Only allow one instance of this job to be queued/running at once.
    def self.lock(*args)
      'BatchPaymentProcessor'
    end

    def self.perform(period = DEFAULT_PERIOD)
      Rails.logger.info("BatchPaymentProcessor starting perform with period #{period}")
      processed_at_min = (Time.now - period).utc.to_s
      params = {
        processed_at_min: processed_at_min,
        status: 'any'
      }
      orders_processed = 0
      Shopify::Utils.search_orders_with_each(params) do |order|
        Fraud::PaymentProcessor.perform(order.id)
        orders_processed += 1
      end

      Rails.logger.info("BatchPaymentProcessor processed #{orders_processed} orders")

      report_metrics(orders_processed)
    end

    def self.report_metrics(orders_processed)
      Librato.increment 'fraud.batch-payment-processor.success', sporadic: true
      Librato.increment 'fraud.batch-payment-processor.orders.count', by: orders_processed, sporadic: true
      Librato.tracker.flush
    end
  end
end
