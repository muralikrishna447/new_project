require 'csv'
require 'resque/plugins/lock'

module Fulfillment
  class RostiOrderSubmitter
    extend Resque::Plugins::Lock
    include Fulfillment::CSVOrderExporter
    include Fulfillment::FulfillableStrategy::OpenFulfillment

    @queue = :RostiOrderSubmitter


    def self.submit_orders_to_rosti(max_quantity, perform_inline, notification_email)
      Rails.logger.info("submit_orders_to_rosti perform_inline : #{perform_inline}")

      filename_date = Time.now.in_time_zone('Asia/Shanghai')

      export_id = SecureRandom.hex
      pending_order_filename = "#{Fulfillment::PendingOrderExporter.type}/#{filename_date.strftime('%Y/%m/%d')}/#{Fulfillment::PendingOrderExporter.type}_#{export_id}.csv"
      submitted_order_filename = "#{Fulfillment::RostiOrderSubmitter.type}/#{Fulfillment::RostiOrderSubmitter.type}_#{filename_date.strftime('%Y-%m-%d')}_#{export_id}.csv"

      params = {
          skus: [Shopify::Order::JOULE_SKU],
          quantity: max_quantity,
          storage: 's3',
          storage_s3_region: Fulfillment::PendingOrderExporter.s3_region,
          storage_s3_bucket: Fulfillment::PendingOrderExporter.s3_bucket,
          storage_filename: pending_order_filename,
          trigger_child_job: true,
          child_job_class: 'Fulfillment::RostiOrderSubmitter',
          child_job_params: {
              notification_email: notification_email,
              skus: [Shopify::Order::JOULE_SKU],
              search_params: {
                  storage: 's3',
                  storage_s3_region: Fulfillment::PendingOrderExporter.s3_region,
                  storage_s3_bucket: Fulfillment::PendingOrderExporter.s3_bucket,
                  storage_filename: pending_order_filename
              },
              open_fulfillment: true,
              quantity: max_quantity,
              storage: 's3',
              storage_s3_region: Fulfillment::RostiOrderSubmitter.s3_region,
              storage_s3_bucket: Fulfillment::RostiOrderSubmitter.s3_bucket,
              storage_filename: submitted_order_filename
          }
      }

      Rails.logger.info("Rosti order export and submit with export id #{export_id} starting with params #{params}")
      if perform_inline
        Fulfillment::PendingOrderExporter.perform(params)
      else
        Resque.enqueue(Fulfillment::PendingOrderExporter, params)
      end

    end

    # Only allow one of these jobs to be enqueued/running
    # at any given time.
    def self.lock(_params)
      Fulfillment::CSVOrderExporter::JOB_LOCK_KEY
    end

    def self.configure(params)
      raise 's3_bucket is a required param' unless params[:s3_bucket]
      raise 's3_region is a required param' unless params[:s3_region]
      @@s3_bucket = params[:s3_bucket]
      @@s3_region = params[:s3_region]
    end

    def self.s3_region
      @@s3_region
    end

    def self.s3_bucket
      @@s3_bucket
    end

    def self.type
      'orders'
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

    RETURN_STATE = 'WA'

    RETURN_ZIP = '98101'

    RETURN_COUNTRY = 'US'

    def self.transform(fulfillable)
      line_items = []
      fulfillable.line_items.each do |line_item|
        rosti_order_number = "#{fulfillable.order.name}-#{line_item.id}"
        quantity = fulfillable.quantity_for_line_item(line_item)
        Rails.logger.info("Rosti order export adding order with id #{fulfillable.order.id} and line item with id #{line_item.id} and quantity #{quantity} as Rosti order number #{rosti_order_number}")
        line_items <<
          [
            rosti_order_number,
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
            quantity,
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

    def self.after_save(fulfillables, job_params)
      Librato.increment 'fulfillment.rosti.order-submitter.success', sporadic: true
      Librato.increment 'fulfillment.rosti.order-submitter.count', by: fulfillables.length, sporadic: true
      total_quantity = fulfillables.inject(0) do |sum, fulfillable|
        sum + fulfillable.quantity
      end

      send_notification_email(total_quantity, job_params)

      Librato.increment 'fulfillment.rosti.order-submitter.quantity', by: total_quantity, sporadic: true
      Librato.tracker.flush
    end

    def self.send_notification_email(total_quantity, job_params)

      log_info("RostiOrderSubmitter:send_notification_email(#{total_quantity}, #{job_params})")

      email_address = job_params.fetch(:notification_email, nil) unless job_params.nil?

      if email_address
        begin
          info = {email_address: email_address, total_quantity: total_quantity}
          RostiOrderSubmitterMailer.notification(info).deliver
          Librato.increment 'fulfillment.rosti.order-submitter.mailer.success', sporadic: true
        rescue StandardError => e
          Librato.increment 'fulfillment.rosti.order-submitter.mailer.error', sporadic: true
          Rails.logger.error "RostiOrderSubmitterMailer : failed with error: #{e}, for #{email_address}"
        end
      else
        Librato.increment 'fulfillment.rosti.order-submitter.mailer.skipped', sporadic: true
      end
    end

    def self.log_info(message)
      Rails.logger.info(message)
      if Rails.env.development?
        puts message
      end
    end
  end
end
