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
        '[cs_order_number]',
        '[cs_line_item_number]',
        '[created_at]',
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
        order = fulfillable.order
        line_items <<
          [
            order.id,
            line_item.id,
            order.created_at,
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
