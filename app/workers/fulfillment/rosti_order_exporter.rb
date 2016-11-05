require 'csv'

module Fulfillment
  class RostiOrderExporter
    include Fulfillment::CSVOrderExporter

    @queue = :RostiOrderExporter

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
        skus: [Shopify::Order::JOULE_SKU],
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
        '[return_address_name]',
        '[return_address_company]',
        '[return_address_line_1]',
        '[return_address_line_2]',
        '[return_address_city]',
        '[return_address_state]',
        '[return_address_zip]',
        '[return_address_country]'
      ]
    end

    RETURN_NAME = 'Shipping Department'

    RETURN_COMPANY = 'ChefSteps, Inc.'

    RETURN_ADDRESS_1 = '1501 Western Ave STE 600'

    RETURN_ADDRESS_2 = ''

    RETURN_CITY = 'Seattle'

    RETURN_STATE = 'WA',

    RETURN_ZIP = '98101'

    RETURN_COUNTRY = 'US'

    def self.transform(fulfillable)
      line_items = []
      fulfillable.line_items.each do |line_item|
        line_items <<
          [
            "#{fulfillable.order.name}-#{line_item.id}",
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
            RETURN_NAME,        # Return address contact name
            RETURN_COMPANY,     # Return address company
            RETURN_ADDRESS_1,   # Return address line 1
            RETURN_ADDRESS_2,   # Return address line 2
            RETURN_CITY,        # Return address city
            RETURN_STATE,       # Return address state
            RETURN_ZIP,         # Return address ZIP
            RETURN_COUNTRY      # Return address country
          ]
      end
      line_items
    end
  end
end
