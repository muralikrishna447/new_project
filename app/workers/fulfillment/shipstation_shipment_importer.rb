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
        order_number = csv_row[ORDER_NUMBER_COLUMN]
        tracking_number = csv_row[TRACKING_NUMBER_COLUMN]
        carrier = csv_row[CARRIER_COLUMN]

        Rails.logger.info("ShipStation shipment import processing order number #{order_number} with tracking number #{tracking_number} and carrier #{carrier}")

        order = Shopify::Utils.order_by_name(order_number.delete('#'))
        raise "Order with number #{order_number} not found" unless order
        joule_line_item = joule_line_item(order)

        shipments << Fulfillment::Shipment.new(
          order: order,
          fulfillments: fulfillments(order, [joule_line_item.id]),
          tracking_company: carrier,
          tracking_numbers: [tracking_number],
          serial_numbers: []
        )
      end
      shipments
    end

    def self.joule_line_item(shopify_order)
      joule_line_items = []
      shopify_order.line_items.each do |line_item|
        joule_line_items << line_item if line_item.sku == 'cs10001'
      end
      if joule_line_items.length > 1
        raise "Order with id #{shopify_order.id} has multiple Joule line items, expected only one"
      elsif joule_line_items.empty?
        raise "Order with id #{shopify_order.id} contains no Joule line item"
      end
      joule_line_items.first
    end
  end
end
