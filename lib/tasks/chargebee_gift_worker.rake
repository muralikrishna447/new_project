
task :chargebee_gift_worker, [:limit] => :environment do |t, limit|
  Rails.logger.info("ChargeBeeGiftWorker task starting with limit=#{limit}")
  Resque.enqueue(ChargeBeeWorkers::ChargeBeeGiftWorker, {
      :limit => limit
  })
end
