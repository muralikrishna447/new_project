require 'csv'
require_relative 'csv_order_exporter'

module Fulfillment
  class ThermoworksOrderExporter
    include Fulfillment::CSVOrderExporter

    THERMOWORKS_SKUS = [
      'THS-234-407',
      'THS-234-417',
      'THS-234-427',
      'THS-234-437',
      'THS-234-447',
      'THS-234-457',
      'THS-234-477',
      'THS-234-487',
      'THS-234-497',
      'THS-234-507',
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
      elsif sku.start_with?('THS-234')
        return "Thermapen Mk4 : #{sku}"
      end

      raise "Unexpected SKU #{sku}"
    end

    def self.get_name(shipping_address)
      # Sometimes the customer name ends up all in the `last_name`
      # field... likely a customer import issue.  Manually fix here
      full = shipping_address.name
      first = shipping_address.first_name
      last = shipping_address.last_name
      if first.length < 1
        parts = full.split
        first = parts[0]
        last = parts[1..-1].join(' ')
        Rails.logger.debug("Fixing name #{full}: [#{first}] [#{last}]")
      end
      return {full_name: full, first_name: first, last_name: last}
    end

    def self.transform(fulfillable)
      line_items = []
      fulfillable.line_items.each do |line_item|
        order = fulfillable.order
        name = get_name(fulfillable.order.shipping_address)

        line_items <<
          [
            order.id,
            line_item.id,
            order.created_at,
            name[:full_name],
            name[:first_name],
            name[:last_name],
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
