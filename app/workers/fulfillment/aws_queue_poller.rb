require 'aws-sdk'
require 'retriable'

################### HOW IT WORKS #############################################
#
# Heroku scheduler is configured to invoke this task with via rake
#
# bundle exec rake aws:run_task_if_queued[TASK_NAME]
#
# That rake task queues this poller up in resque to run in the background
# TASK_NAME is the key here, it's in both the name of the SQS queue to check:
#
# https://sqs.us-east-1.amazonaws.com/021963864089/task-poller-{RAILS_ENV}-{TASK_NAME}
#
# and the name of the dispatch_{TASK_NAME} method in the Fulfillment::AwsQueueWorker
#
# Basically if the Fulfillment::AwsQueuePoller finds an available message in the
# the specific queue, then dispatch_{TASK_NAME} method in the Fulfillment::AwsQueueWorker
# is called inline (Errors are captured and keep the message in the Queue for next time)
#
# If the dispatch_{TASK_NAME} method completes successfully the message is deleted
#
# The goal here is that we can run the rake tasks in the Heroku scheduler (which does
# not support cron type scheduling) on a recurring basis and nothing will happen
# unless another task has dropped a message in that tasks SQS queue
#
############################################################################

module Fulfillment
  class AwsQueuePoller

    extend Resque::Plugins::Lock

    @queue = :AwsQueuePoller

    TASK_POLLER = 'task-poller'

    LOGGING_NAMESPACE = (TASK_POLLER + '-').downcase.gsub(/\s+/, '-')

    QUEUE_LABEL = LOGGING_NAMESPACE + Rails.env + '-'

    RESQUE_LOCK_NAME = (LOGGING_NAMESPACE + '-lock').to_sym

    LIBRATO_PREFIX = LOGGING_NAMESPACE.tr('-', '.')

    def self.lock(_params)
      RESQUE_LOCK_NAME
    end

    def self.configure(params)
      @@aws_region = params[:aws_region]
      @@task_queue_prefix = params[:task_queue_prefix]
    end

    def self.aws_region
      @@aws_region
    end

    def self.sqs_url(task_name)
      "#{@@task_queue_prefix}#{QUEUE_LABEL}#{task_name}"
    end

    def self.perform(task_name)
      begin
        librato_increment('started', task_name)

        sqs = sqs_client
        result = nil
        Retriable.retriable tries: 3 do
          librato_increment('attempt.receive', task_name)
          result = sqs.receive_message(queue_url: sqs_url(task_name))
        end

        if result.messages.empty?
          librato_increment('empty.queue', task_name)
        else
          result.messages.each do |received_message|
            librato_increment('received', task_name)
            Rails.logger.info("AwsQueuePoller received message #{received_message}")

            process_sqs_message(received_message.body, task_name)

            Retriable.retriable tries: 3 do
              librato_increment('delete.message', task_name)
              sqs.delete_message(
                  queue_url:  sqs_url(task_name),
                  receipt_handle: received_message.receipt_handle
              )
            end
          end
        end
      rescue StandardError => error
        log_error error
        librato_increment('failure', task_name)
      else
        librato_increment('success', task_name)
      ensure
        begin
          Librato.tracker.flush
          Rails.logger.info('Librato Tracker Flush')
        rescue StandardError => error
          log_error error
        end
      end
    end

    def self.process_sqs_message(message, task_name)
      librato_increment('processing.starting', task_name)

      params = {
          :task => task_name,
          :message => message
      }

      Fulfillment::AwsQueueWorker.perform(params);

      librato_increment('processing.complete', task_name)
    end

    # Stub these out for unit tests.
    def self.sqs_client
      Aws::SQS::Client.new(region: aws_region)
    end

    def self.librato_increment(subkey, task_name)
      librato_metric = "#{LIBRATO_PREFIX}#{task_name}.#{subkey}"
      source = sqs_url(task_name)
      Rails.logger.info("Librato Increment -> #{librato_metric} : source => #{source}")
      begin
        Librato.increment librato_metric, sporadic: true, source: source
      rescue StandardError => error
        # Errors will be reported on flush
        Rails.logger.error error.message
      end
    end

    def self.log_error(error)
      Rails.logger.error error.message
      error.backtrace.each { |line| Rails.logger.error line }
    end

  end
end
