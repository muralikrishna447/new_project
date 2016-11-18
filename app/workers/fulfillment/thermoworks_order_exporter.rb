require 'csv'
require_relative 'csv_order_exporter'

module Fulfillment
  class ThermoworksOrderExporter
    include Fulfillment::CSVOrderExporter

    THERMOWORKS_SKUS = [
      'THS-231-207',
      'THS-231-227',
      'THS-231-237',
      'THS-231-247',
      'THS-231-277',
      'THS-231-357',
      'TX-3100-BL',
      'TX-3100-BK',
      'TX-3100-GR',
      'TX-3100-OR',
      'TX-3100-PK',
      'TX-3100-PR',
      'TX-3100-RD',
      'TX-3100-WH',
      'TX-3100-YL',
    ]

    def self.type
      'orders'
    end

    def self.job_params(params)
      job_params = params.merge(
        skus: THERMOWORKS_SKUS,
        storage_filename: "thermoworks-#{params[:date]}.csv"
      )
      job_params
    end

    def self.schema
      [
        'ChefSteps Order ID',
        'ChefSteps Line Item ID',
        'Order Creation Date',
        'Recipient Name',
        'Recipient First Name',
        'Recipient Last Name',
        'Recipient Company',
        'Address Line 1',
        'Address Line 2',
        'City',
        'State',
        'Zip',
        'Phone',
        'Email',
        'SKU',
        'Quantity',

        # To be filled in by Thermoworks
        'Ship Date',
        'Tracking Number',
      ]
    end

    def self.transform_sku(sku)

      if sku.start_with?('TX')
        return "ThermoPop : #{sku}"
      elsif sku.start_with?('THS')
        return "Classic Thermapen : #{sku}"
      end

      raise "Unexpected SKU #{sku}"
    end

    def self.transform(fulfillable)
      line_items = []
      fulfillable.line_items.each do |line_item|
        order = fulfillable.order
        # Thermoworks *loses* the line item, apparently, so add it to the order_id
        order_id = "#{order.id}-#{line_item.id}"
        line_items <<
          [
            order_id,
            line_item.id,
            order.created_at,
            fulfillable.order.shipping_address.name,
            fulfillable.order.shipping_address.first_name,
            fulfillable.order.shipping_address.last_name,
            fulfillable.order.shipping_address.company,
            fulfillable.order.shipping_address.address1,
            fulfillable.order.shipping_address.address2,
            fulfillable.order.shipping_address.city,
            fulfillable.order.shipping_address.province_code,
            fulfillable.order.shipping_address.zip,
            fulfillable.order.shipping_address.phone,
            fulfillable.order.customer.email,
            transform_sku(line_item.sku),
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
