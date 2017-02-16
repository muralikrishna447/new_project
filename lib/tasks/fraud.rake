namespace :fraud do
  task :capture_payments, [:inline, :period_seconds] => :environment do |_t, args|
    args.with_defaults(inline: false, period_seconds: nil)
    Rails.logger.info("Capture payments rake task starting with args #{args}")

    if args[:inline].to_s == 'true'
      if args[:period_seconds]
        Fraud::BatchPaymentProcessor.perform(args[:period_seconds].to_i)
      else
        Fraud::BatchPaymentProcessor.perform
      end
    else
      if args[:period_seconds]
        Resque.enqueue(Fraud::BatchPaymentProcessor, args[:period_seconds].to_i)
      else
        Resque.enqueue(Fraud::BatchPaymentProcessor)
      end
    end
  end  
end
