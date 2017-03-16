namespace :aws do
  desc "Checks AWS SQS Queue for tasks to run - Queue name is task-poller-{RAILS_ENV}-{TASK_NAME} "
  task :run_task_if_queued, [:task_name, :inline] => :environment do |_t, args|
    args.with_defaults(inline: false)
    Rails.logger.info("AwsQueuePoller starting with params #{args}")
    if args[:inline].to_s == 'true'

      if Rails.env.production?
        Rails.logger.error "AWS:RUN_TASK_IF_QUEUED -> INLINE IS ONLY FOR DEV TESTING, ALWAYS RUN REAL JOBS with inline=false"
      end

      Fulfillment::AwsQueuePoller.perform(args[:task_name].to_s)
    else
      Resque.enqueue(Fulfillment::AwsQueuePoller, args[:task_name].to_s)
    end
  end
end
