require 'csv'
require 'resque/plugins/lock'

module Fulfillment
  class FbaOrderSubmitter
    extend Resque::Plugins::Lock
    include Fulfillment::CSVOrderExporter
    include Fulfillment::FulfillableStrategy::OpenFulfillment

    @queue = :FbaOrderSubmitter

    def self.lock(_params)
      'fulfillment-fba-order-submitter'
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
        'order_id',
        'seller_fulfillment_order_id',
        'displayable_order_id',
        'displayable_order_date_time',
        'displayable_order_comment',
        'shipping_speed_category',
        'shipping_address_name',
        'shipping_address_line1',
        'shipping_address_line2',
        'shipping_address_line3',
        'shipping_address_city',
        'shipping_address_state',
        'shipping_address_country',
        'shipping_address_postal_code',
        'shipping_address_phone'
      ]
    end

    def self.transform(fulfillable)
      fulfillable.line_items.map do |item|
        seller_fulfillment_order_id = Fulfillment::Fba.seller_fulfillment_order_id(fulfillable, item)
        displayable_order_id = Fulfillment::Fba.displayable_order_id(fulfillable, item)
        quantity = fulfillable.quantity_for_line_item(item)
        Rails.logger.info("FbaOrderSubmitter adding order with id #{fulfillable.order.id} " \
                          "and line item with id #{item.id} and quantity #{quantity} " \
                          "as FBA seller fulfillment order id #{seller_fulfillment_order_id}")
        [
          fulfillable.order.id,
          seller_fulfillment_order_id,
          displayable_order_id,
          fulfillable.order.processed_at,
          COMMENT,
          SHIPPING_SPEED,
          fulfillable.order.shipping_address.address1,
          fulfillable.order.shipping_address.address2,
          fulfillable.order.shipping_address.company,
          fulfillable.order.shipping_address.city,
          fulfillable.order.shipping_address.province_code,
          fulfillable.order.shipping_address.country_code,
          fulfillable.order.shipping_address.zip,
          fulfillable.order.shipping_address.phone,
          item.sku,
          quantity
        ]
      end
    end

    def self.after_save(fulfillables, job_params)
      # All this assumes we ship line items separately, obviously
      # needs to change if we ship line items together.
      fba_orders_created = 0
      fba_quantity_submitted = 0
      fulfillables.each do |fulfillable|
        fulfillable.line_items.each do |item|
          # This should really never happen, but let's just be extra
          # careful not to sent SKUs to FBA that are not fulfillable.
          unless Fulfillment::FBA_FULFILLABLE_SKUS.include?(item.sku)
            raise "Order with id #{fulfillable.order.id} and line item with id #{item.id} " \
                  "has sku that is not fulfillable by FBA: #{item.sku}"
          end

          seller_fulfillment_order_id = Fulfillment::Fba.seller_fulfillment_order_id(fulfillable, item)
          existing_order = Fulfillment::Fba.fulfillment_order(seller_fulfillment_order_id)
          if existing_order
            submitted_time = existing_order.fetch('FulfillmentOrder').fetch('ReceivedDateTime')
            Rails.logger.info "FbaOrderSubmitter order with id #{fulfillable.order.id} " \
                              "and seller_fulfillment_order_id  #{seller_fulfillment_order_id} " \
                              "was already submitted to FBA at #{submitted_time}, not submitting again"
          elsif job_params[:create_fulfillment_orders]
            Fulfillment::Fba.create_fulfillment_order(fulfillable, item)
            fba_orders_created += 1
            fba_quantity_submitted += fulfillable.quantity_for_line_item(item)
          end
        end
      end

      report_metrics(fba_orders_created, fba_quantity_submitted)
    end

    def self.report_metrics(fba_orders_created, fba_quantity_submitted)
      Librato.increment 'fulfillment.fba.order-submitter.success', sporadic: true
      Librato.increment 'fulfillment.fba.order-submitter.count', by: fba_orders_created, sporadic: true
      Librato.increment 'fulfillment.fba.order-submitter.quantity', by: fba_quantity_submitted, sporadic: true
      Librato.tracker.flush
    end

    def self.submit_orders_to_fba(max_quantity, perform_inline)
      filename_date = Time.now.in_time_zone('Pacific Time (US & Canada)')
      export_id = SecureRandom.hex
      pending_order_filename = "#{Fulfillment::PendingOrderExporter.type}/fba/#{filename_date.strftime('%Y/%m/%d')}/#{Fulfillment::PendingOrderExporter.type}_#{export_id}.csv"
      submitted_order_filename = "archives/fba/#{Fulfillment::FbaOrderSubmitter.type}/#{Fulfillment::FbaOrderSubmitter.type}_#{filename_date.strftime('%Y-%m-%d')}_#{export_id}.csv"

      params = {
        skus: Fulfillment::FBA_FULFILLABLE_SKUS,
        quantity: max_quantity, # Ideally this should be derived from current FBA inventory levels
        storage: 's3',
        storage_s3_region: Fulfillment::PendingOrderExporter.s3_region,
        storage_s3_bucket: Fulfillment::PendingOrderExporter.s3_bucket,
        storage_filename: pending_order_filename,
        trigger_child_job: true,
        child_job_class: 'Fulfillment::FbaOrderSubmitter',
        child_job_params: {
          skus: Fulfillment::FBA_FULFILLABLE_SKUS,
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

      Rails.logger.info("FbaOrderSubmitter starting with export id #{export_id} and params #{params}")
      if perform_inline
        Fulfillment::PendingOrderExporter.perform(params)
      else
        Resque.enqueue(Fulfillment::PendingOrderExporter, params)
      end
    end
  end
end
