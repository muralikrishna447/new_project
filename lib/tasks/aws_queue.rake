namespace :aws do
  desc "Checks AWA SQS Queue for tasks to run"
  task :run_task_if_queued, [:task_name, :inline] => :environment do |_t, args|
    args.with_defaults(inline: false)
    Rails.logger.info("AwsQueuePoller starting with params #{args}")
    if args[:inline].to_s == 'true'
      Fulfillment::AwsQueuePoller.perform(args[:task_name].to_s)
    else
      Resque.enqueue(Fulfillment::AwsQueuePoller, args[:task_name].to_s)
    end
  end
end
