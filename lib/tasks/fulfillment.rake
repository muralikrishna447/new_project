namespace :fulfillment do
  task :rosti_export_and_submit_orders, [:max_quantity, :inline] => :environment do |_t, args|
    args.with_defaults(inline: false)
    Rails.logger.info("Rosti order export and submit rake task starting with args #{args}")

    export_id = SecureRandom.hex
    pending_order_filename = "#{Fulfillment::PendingOrderExporter.type}/#{Time.now.utc.strftime('%Y/%m/%d')}/#{Fulfillment::PendingOrderExporter.type}_#{export_id}.csv"
    submitted_order_filename = "#{Fulfillment::RostiOrderSubmitter.type}/#{Fulfillment::RostiOrderSubmitter.type}_#{Time.now.utc.strftime('%Y-%m-%d')}_#{export_id}.csv"
    max_quantity = args[:max_quantity].to_i

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
    if args[:inline]
      Fulfillment::PendingOrderExporter.perform(params)
    else
      Resque.enqueue(Fulfillment::PendingOrderExporter, params)
    end
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
      skus: [Shopify::Order::JOULE_SKU],
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
    if args[:inline]
      Fulfillment::RostiOrderSubmitter.perform(params)
    else
      Resque.enqueue(Fulfillment::RostiOrderSubmitter, params)
    end
  end
end
