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

    def self.perform(params)
      job_params = params.merge(
        skus: ['cs10001'],
        storage_filename: "#{type}-#{Time.now.utc.iso8601}.csv"
      )
      job_params[:storage] ||= 's3'
      if job_params[:storage] == 's3'
        job_params[:storage_s3_bucket] = @@s3_bucket
        job_params[:storage_s3_region] = @@s3_region
      end
      inner_perform(job_params)
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
            'Shipping Department',        # Return address contact name
            'ChefSteps, Inc.',            # Return address company
            '1501 Western Ave STE 600',   # Return address line 1
            '',                           # Return address line 2
            'Seattle',                    # Return address city
            'WA',                         # Return address state
            '98101',                      # Return address ZIP
            'US'                          # Return address country
          ]
      end
      line_items
    end
  end
end
