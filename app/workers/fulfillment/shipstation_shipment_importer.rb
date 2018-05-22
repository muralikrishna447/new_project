require 'shopify_api'

module Fulfillment
  module ShipstationShipmentImporter
    include Fulfillment::CSVShipmentImporter

    @queue = :ShipstationShipmentImporter

    ORDER_NUMBER_COLUMN = 'Order - Number'

    TRACKING_NUMBER_COLUMN = 'Shipment - Tracking Number'

    CARRIER_COLUMN = 'Shipment - Carrier'

    def self.job_params(params)
      job_params = params.merge(headers: true)
      job_params[:storage] ||= 'file'
      job_params
    end

    def self.to_shipments(csv_rows)
      shipments = []
      csv_rows.each do |csv_row|
        order_number_parts = csv_row[ORDER_NUMBER_COLUMN].split('-')
        order_number = order_number_parts[0]
        line_item_id = order_number_parts[1].to_i
        tracking_number = csv_row[TRACKING_NUMBER_COLUMN]
        carrier = csv_row[CARRIER_COLUMN]

        Rails.logger.info "ShipStation shipment import processing order number #{order_number}, " \
                          "line item id #{line_item_id}, " \
                          "tracking number #{tracking_number} and carrier #{carrier}"

        order = Shopify::Utils.order_by_name(order_number.delete('#'))
        raise "Order with number #{order_number} not found" unless order

        shipments << Fulfillment::Shipment.new(
          order: order,
          fulfillments: fulfillments(order, [line_item_id]),
          tracking_company: carrier,
          tracking_numbers: [tracking_number],
          serial_numbers: []
        )
      end
      shipments
    end
  end
end
