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
        '[recipient_name]',
        '[recipient_company]',
        '[recipient_address_line_1]',
        '[recipient_address_line_2]',
        '[recipient_city]',
        '[recipient_state]',
        '[recipient_zip]',
        '[recipient_phone]',
        '[recipient_email]',
        '[sku]',
        '[quantity]',

        # To be filled in by Thermoworks
        '[ship_date]',
        '[tracking_number]',
      ]
    end

    def self.transform(fulfillable)
      line_items = []
      fulfillable.line_items.each do |line_item|
        order_number = fulfillable.order.id
        line_items <<
          [
            order_number,
            fulfillable.order.shipping_address.name,
            fulfillable.order.shipping_address.company,
            fulfillable.order.shipping_address.address1,
            fulfillable.order.shipping_address.address2,
            fulfillable.order.shipping_address.city,
            fulfillable.order.shipping_address.province_code,
            fulfillable.order.shipping_address.zip,
            fulfillable.order.shipping_address.phone,
            fulfillable.order.customer.email,
            line_item.sku,
            line_item.quantity,

            # To be filled in by Thermoworks
            '',
            '',
          ]
      end
      line_items
    end
  end
end
