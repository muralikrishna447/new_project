require 'shopify_api'
require 'set'

module Fulfillment
  module RostiShipmentImporter
    include Fulfillment::CSVShipmentImporter

    @queue = :RostiShipmentImporter

    ROSTI_ORDER_NUMBER_COLUMN = '[order_number]'

    SERIAL_NUMBER_COLUMN = '[tran]'

    TRACKING_NUMBER_COLUMN = '[crn]'

    def self.configure(params)
      raise 's3_bucket is a required param' unless params[:s3_bucket]
      raise 's3_region is a required param' unless params[:s3_region]
      @@s3_bucket = params[:s3_bucket]
      @@s3_region = params[:s3_region]
    end

    def self.job_params(params)
      job_params = params.merge(headers: true)
      job_params[:storage] ||= 's3'
      if job_params[:storage] == 's3'
        job_params[:storage_s3_bucket] = @@s3_bucket
        job_params[:storage_s3_region] = @@s3_region
      end
      job_params
    end

    def self.to_shipments(csv_rows)
      # With orders that have quantity > 1, Rosti sends back multiple
      # lines in the shipment import file for each order/line item b/c
      # they ship each individual unit under a separate tracking number.
      # So first we iterate through the import file and build an array
      # of tracking numbers and serial numbers for each order/line item.
      rosti_order_numbers = Set.new
      fulfillment_tracking_numbers = {}
      fulfillment_serial_numbers = {}
      csv_rows.each do |csv_row|
        validate(csv_row)
        rosti_order_number = csv_row[ROSTI_ORDER_NUMBER_COLUMN]
        rosti_order_numbers.add(rosti_order_number)
        fulfillment_tracking_numbers[rosti_order_number] ||= []
        fulfillment_tracking_numbers[rosti_order_number] << csv_row[TRACKING_NUMBER_COLUMN]
        fulfillment_serial_numbers[rosti_order_number] ||= []
        fulfillment_serial_numbers[rosti_order_number] << csv_row[SERIAL_NUMBER_COLUMN]
      end

      shipments = []
      rosti_order_numbers.each do |rosti_order_number|
        order_number_parts = rosti_order_number.split('-')
        order_number = order_number_parts[0]
        line_item_id = order_number_parts[1].to_i
        tracking_numbers = fulfillment_tracking_numbers[rosti_order_number]
        serial_numbers = fulfillment_serial_numbers[rosti_order_number]
        Rails.logger.info("Rosti shipment import processing order number #{order_number}, line item id #{line_item_id}, tracking numbers #{tracking_numbers}, serial numbers #{serial_numbers}")

        order = Shopify::Utils.order_by_name(order_number.delete('#'))
        raise "Order with number #{order_number} not found" unless order
        Rails.logger.info("Rosti shipment import found order with id #{order.id} for order number #{order_number}")

        shipments << Fulfillment::Shipment.new(
          order: order,
          fulfillments: fulfillments(order, [line_item_id]),
          tracking_company: 'FedEx',
          tracking_numbers: tracking_numbers,
          serial_numbers: serial_numbers
        )
      end
      shipments
    end

    def self.validate(row)
      unless row[ROSTI_ORDER_NUMBER_COLUMN] =~ /^#[0-9]+-[0-9]+$/
        raise "Rosti order number column is invalid: #{row[ROSTI_ORDER_NUMBER_COLUMN]}"
      end

      unless row[SERIAL_NUMBER_COLUMN] && !row[SERIAL_NUMBER_COLUMN].empty?
        Rails.logger.warn("Rosti shipment import found empty serial number for row #{row.inspect}")
      end

      unless row[TRACKING_NUMBER_COLUMN] && !row[TRACKING_NUMBER_COLUMN].empty?
        raise "Tracking number column is invalid: #{row['CRN']}"
      end
    end
  end
end
