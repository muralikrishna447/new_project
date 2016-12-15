require 'csv'
require 'resque/plugins/lock'

module Fulfillment
  # Exports order IDs (and some order data for the record) in a generic
  # format. This can be used as the first phase in a two-phase export.
  # As a second phase, an exporter can use the file produced by this
  # exporter as input and open fulfillments for those orders.
  class PendingOrderExporter
    extend Resque::Plugins::Lock
    include Fulfillment::CSVOrderExporter
    include Fulfillment::FulfillableStrategy::Export

    @queue = :PendingOrderExporter

    # Only allow one of these jobs to be enqueued/running
    # at any given time.
    def self.lock(_params)
      Fulfillment::JOB_LOCK_KEY
    end

    def self.configure(params)
      raise 's3_bucket is a required param' unless params[:s3_bucket]
      raise 's3_region is a required param' unless params[:s3_region]
      @@s3_bucket = params[:s3_bucket]
      @@s3_region = params[:s3_region]
    end

    def self.s3_region
      @@s3_region
    end

    def self.s3_bucket
      @@s3_bucket
    end

    def self.type
      'orders-pending'
    end

    def self.job_params(params)
      # We never want to open fulfillments in this export.
      params.merge(open_fulfillment: false)
    end

    def self.schema
      [
        'order_id',
        'order_name',
        'line_item_id',
        'processed_at',
        'recipient_company',
        'recipient_name',
        'recipient_address_line_1',
        'recipient_address_line_2',
        'recipient_city',
        'recipient_state',
        'recipient_zip',
        'recipient_country',
        'recipient_phone',
        'sku',
        'quantity'
      ]
    end

    def self.transform(fulfillable)
      line_items = []
      fulfillable.line_items.each do |line_item|
        Rails.logger.info("Pending order export adding order with id #{fulfillable.order.id} and line item with id #{line_item.id} and quantity #{line_item.fulfillable_quantity}")
        line_items <<
          [
            fulfillable.order.id,
            fulfillable.order.name,
            line_item.id,
            fulfillable.order.processed_at,
            fulfillable.order.shipping_address.company,
            fulfillable.order.shipping_address.name,
            fulfillable.order.shipping_address.address1,
            fulfillable.order.shipping_address.address2,
            fulfillable.order.shipping_address.city,
            fulfillable.order.shipping_address.province_code,
            fulfillable.order.shipping_address.zip,
            fulfillable.order.shipping_address.country_code,
            fulfillable.order.shipping_address.phone,
            line_item.sku,
            line_item.fulfillable_quantity
          ]
      end
      line_items
    end
  end
end
