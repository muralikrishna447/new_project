require 'shopify_api'

module Fulfillment
  module RostiShipmentImporter
    include Fulfillment::CSVShipmentImporter

    @queue = :RostiShipmentImporter

    SHIPMENT_ID_COLUMN = 'order_number'

    SERIAL_NUMBER_COLUMN = 'TRAN'

    TRACKING_NUMBER_COLUMN = 'CRN'

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

    def self.to_shipment(csv_row)
      validate(csv_row)

      shipment_id_parts = csv_row[SHIPMENT_ID_COLUMN].split('-')
      order_number = shipment_id_parts[0]
      line_item_id = shipment_id_parts[1]
      tracking_number = csv_row[TRACKING_NUMBER_COLUMN]
      serial_number = csv_row[SERIAL_NUMBER_COLUMN]

      order = Shopify::Utils.order_by_name(order_number.delete('#'))
      raise "Order with number #{order_number} not found" unless order

      Fulfillment::Shipment.new(
        order: order,
        fulfillments: fulfillments(order, [line_item_id]),
        tracking_company: 'FedEx',
        tracking_numbers: [tracking_number],
        serial_numbers: [serial_number]
      )
    end

    def self.validate(row)
      unless row[SHIPMENT_ID_COLUMN] =~ /^#[0-9]+-[0-9]+$/
        raise "Order number column is invalid: #{row[SHIPMENT_ID_COLUMN]}"
      end

      unless row[SERIAL_NUMBER_COLUMN] && !row[SERIAL_NUMBER_COLUMN].empty?
        # TODO add log message. Shouldn't raise an exception here.
      end

      unless row[TRACKING_NUMBER_COLUMN] && !row[TRACKING_NUMBER_COLUMN].empty?
        raise "Tracking number column is invalid: #{row['CRN']}"
      end
    end
  end
end
