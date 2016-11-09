require 'csv'
require_relative 'csv_order_exporter'

module Fulfillment
  class ThermoworksOrderExporter
    include Fulfillment::CSVOrderExporter

    @queue = :ThermoworksOrderExporter

    def self.configure(params)
      raise 's3_bucket is a required param' unless params[:s3_bucket]
      raise 's3_region is a required param' unless params[:s3_region]
      @@s3_bucket = params[:s3_bucket]
      @@s3_region = params[:s3_region]
    end

    def self.type
      'orders'
    end

    def self.job_params(params)
      job_params = params.merge(
        skus: ["THS-231-207"],
        storage_filename: "#{type}-#{Time.now.utc.iso8601}.csv"
      )
      job_params[:storage] ||= 's3'
      if job_params[:storage] == 's3'
        job_params[:storage_s3_bucket] = @@s3_bucket
        job_params[:storage_s3_region] = @@s3_region
      end
      job_params
    end

    def self.schema
      [
        '[order_number]',
        '[processed_at]',
        '[recipient_company]',
        '[recipient_name]',
        '[recipient_address_line_1]',
        '[recipient_address_line_2]',
        '[recipient_city]',
        '[recipient_state]',
        '[recipient_zip]',
        '[recipient_country]',
        '[recipient_phone]',
        '[sku]',
        '[quantity]',
      ]
    end

    def self.transform(fulfillable)
      line_items = []
      fulfillable.line_items.each do |line_item|
        rosti_order_number = "#{fulfillable.order.name}-#{line_item.id}"
        Rails.logger.info("Rosti order export adding order with id #{fulfillable.order.id} and line item with id #{line_item.id} and quantity #{line_item.quantity} as Rosti order number #{rosti_order_number}")
        line_items <<
          [
            rosti_order_number,
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
            line_item.quantity,
          ]
      end
      line_items
    end
  end
end
