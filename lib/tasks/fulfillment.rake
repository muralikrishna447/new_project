namespace :fulfillment do
  task :rosti_export_and_submit_orders, [:max_quantity, :inline, :notification_email] => :environment do |_t, args|
    args.with_defaults(notification_email: nil)
    args.with_defaults(inline: false)
    args.with_defaults(max_quantity: 1500)
    Fulfillment::RostiOrderSubmitter.submit_orders_to_rosti( args[:max_quantity].to_i, args[:inline].to_s == 'true', args[:notification_email].to_s)
  end

  task :rosti_submit_orders, [:pending_order_filename, :export_id, :max_quantity, :inline] => :environment do |_t, args|
    # Normally you would only execute this as a recovery step in case the
    # submission job fails, so you want to take all the quantity in the pending
    # file and run it inline.
    args.with_defaults(inline: true)
    Rails.logger.info("Rosti order submit rake task starting with args #{args}")

    export_id = args[:export_id]
    max_quantity = args[:max_quantity].to_i

    params = {
      skus: Fulfillment::ROSTI_FULFILLABLE_SKUS,
      search_params: {
        storage: 's3',
        storage_filename: args[:pending_order_filename],
        storage_s3_region: Fulfillment::PendingOrderExporter.s3_region,
        storage_s3_bucket: Fulfillment::PendingOrderExporter.s3_bucket
      },
      open_fulfillment: true,
      quantity: max_quantity,
      storage: 's3',
      storage_s3_region: Fulfillment::RostiOrderSubmitter.s3_region,
      storage_s3_bucket: Fulfillment::RostiOrderSubmitter.s3_bucket,
      storage_filename: "#{Fulfillment::RostiOrderSubmitter.type}/#{Fulfillment::RostiOrderSubmitter.type}_#{Time.now.utc.strftime('%Y-%m-%d')}_#{export_id}.csv"
    }

    Rails.logger.info("Rosti order submit with export id #{export_id} starting with params #{params}")
    if args[:inline].to_s == 'true'
      Fulfillment::RostiOrderSubmitter.perform(params)
    else
      Resque.enqueue(Fulfillment::RostiOrderSubmitter, params)
    end
  end

  task :fba_export_and_submit_orders, [:sku, :max_quantity, :inline] => :environment do |_t, args|
    args.with_defaults(inline: false)
    max_quantity = args[:max_quantity]
    max_quantity ||= max_quantity.to_i
    Fulfillment::FbaOrderSubmitter.submit_orders_to_fba(
      sku: args[:sku],
      perform_inline: args[:inline],
      max_quantity: max_quantity
    )
  end

  task :fba_submit_orders, [:pending_order_filename, :export_id, :sku, :max_quantity, :inline] => :environment do |_t, args|
    # Normally you would only execute this as a recovery step in case the
    # submission job fails, so you want to take all the quantity in the pending
    # file and run it inline.
    args.with_defaults(inline: true)
    Rails.logger.info "FBA order submit rake task starting with args #{args}"

    export_id = args[:export_id]
    max_quantity = args[:max_quantity].to_i
    filename_date = Time.now.in_time_zone('Pacific Time (US & Canada)')

    params = {
      skus: [args[:sku]],
      search_params: {
        storage: 's3',
        storage_filename: args[:pending_order_filename],
        storage_s3_region: Fulfillment::PendingOrderExporter.s3_region,
        storage_s3_bucket: Fulfillment::PendingOrderExporter.s3_bucket
      },
      open_fulfillment: true,
      create_fulfillment_orders: true,
      quantity: max_quantity,
      storage: 's3',
      storage_s3_region: Fulfillment::FbaOrderSubmitter.s3_region,
      storage_s3_bucket: Fulfillment::FbaOrderSubmitter.s3_bucket,
      storage_filename: "archives/fba/#{Fulfillment::FbaOrderSubmitter.type}/#{Fulfillment::FbaOrderSubmitter.type}_#{filename_date.strftime('%Y-%m-%d')}_#{export_id}.csv"
    }

    Rails.logger.info "FBA order submit with export id #{export_id} starting with params #{params}"
    if args[:inline].to_s == 'true'
      Fulfillment::FbaOrderSubmitter.perform(params)
    else
      Resque.enqueue(Fulfillment::FbaOrderSubmitter, params)
    end
  end

  task :rosti_poll_shipments, [:inline] => :environment do |_t, args|
    args.with_defaults(inline: false)

    params = { complete_fulfillment: true }
    Rails.logger.info("Rosti shipment poller starting with params #{params}")
    if args[:inline].to_s == 'true'
      Fulfillment::RostiShipmentPoller.perform(params)
    else
      Resque.enqueue(Fulfillment::RostiShipmentPoller, params)
    end
  end

  task :validate_shipping_addresses, [:inline] => :environment do |_t, args|
    args.with_defaults(inline: false)

    skus = Fulfillment::ROSTI_FULFILLABLE_SKUS
    if args[:inline]
      Fulfillment::ShippingAddressValidator.perform(skus)
    else
      Resque.enqueue(Fulfillment::ShippingAddressValidator, skus)
    end
  end
end
