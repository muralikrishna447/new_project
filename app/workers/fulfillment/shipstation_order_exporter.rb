require 'csv'

module Fulfillment
  class ShipstationOrderExporter
    include Fulfillment::CSVOrderExporter

    @queue = :ShipstationOrderExporter

    def self.type
      'orders'
    end

    def self.job_params(params)
      job_params = params.merge(skus: ['cs10001'])
      job_params[:storage] ||= 'stdout'
      job_params
    end

    def self.schema
      [
        'id',
        'name',
        'processed_at',
        'shipping_name',
        'shipping_company',
        'shipping_address_1',
        'shipping_address_2',
        'shipping_city',
        'shipping_province',
        'shipping_zip',
        'shipping_country',
        'email',
        'shipping_phone',
        'sku',
        'quantity',
        'tags'
      ]
    end

    def self.transform(fulfillable)
      line_items = []
      fulfillable.line_items.each do |line_item|
        Rails.logger.info("ShipStation order export adding order with id #{fulfillable.order.id} and line item with id #{line_item.id} and quantity #{line_item.quantity}")
        line_items <<
          [
            fulfillable.order.id,
            fulfillable.order.name,
            fulfillable.order.processed_at,
            fulfillable.order.shipping_address.name,
            fulfillable.order.shipping_address.company,
            fulfillable.order.shipping_address.address1,
            fulfillable.order.shipping_address.address2,
            fulfillable.order.shipping_address.city,
            fulfillable.order.shipping_address.province_code,
            fulfillable.order.shipping_address.zip,
            fulfillable.order.shipping_address.country_code,
            fulfillable.order.email,
            fulfillable.order.shipping_address.phone,
            line_item.sku,
            line_item.fulfillable_quantity,
            fulfillable.order.tags
          ]
      end
      line_items
    end

    def self.include_order?(order)
      # Filter out any order that has filtered tags
      unless (Shopify::Utils.order_tags(order) & FILTERED_TAGS).empty?
        Rails.logger.info("ShipStation order export filtering order with id #{order.id} because it has one or more filtered tags: #{order.tags}")
        return false
      end
      true
    end
  end
end
