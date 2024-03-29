
task :chargebee_gift_worker, [:limit] => :environment do |t, args|
  Rails.logger.info("ChargeBeeGiftWorker task starting with limit=#{args[:limit]}")
  Resque.enqueue(ChargeBeeWorkers::ChargeBeeGiftWorker, {
      :limit => args[:limit]
  })
end
