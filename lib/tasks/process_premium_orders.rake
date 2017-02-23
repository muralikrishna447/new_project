task :process_premium_orders, [:inline, :period_seconds] => :environment do |_t, args|
  args.with_defaults(inline: false, period_seconds: nil)
  Rails.logger.info("Process premium orders rake task starting with args #{args}")

  if args[:inline].to_s == 'true'
    if args[:period_seconds]
      Fraud::BatchPremiumOrderProcessor.perform(args[:period_seconds].to_i)
    else
      Fraud::BatchPremiumOrderProcessor.perform
    end
  else
    if args[:period_seconds]
      Resque.enqueue(Fraud::BatchPremiumOrderProcessor, args[:period_seconds].to_i)
    else
      Resque.enqueue(Fraud::BatchPremiumOrderProcessor)
    end
  end
end
