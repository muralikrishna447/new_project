require 'aws-sdk'
require 'retriable'

module Fulfillment
  class AwsQueuePoller

    LOGGING_NAMESPACE = 'chefsteps_com_task_poller_'+ Rails.env + '_'

    LOCK_QUEUE_NAME = (LOGGING_NAMESPACE + 'lock').to_sym

    LIBRATO_PREFIX = LOGGING_NAMESPACE

    QUEUE_NAME = LOGGING_NAMESPACE

    extend Resque::Plugins::Lock

    @queue = LOCK_QUEUE_NAME

    def self.lock(_params)
      LOCK_QUEUE_NAME
    end

    def self.configure(params)
      @@aws_region = params[:aws_region]
      @@task_queue_prefix = params[:task_queue_prefix]
    end

    def self.aws_region
      @@aws_region
    end

    def self.sqs_url(task_name)
      "#{@@task_queue_prefix}#{QUEUE_NAME}#{task_name}"
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
        Librato.tracker.flush
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
      Rails.logger.info("#{LIBRATO_PREFIX}#{task_name} : #{subkey}")
      begin
        Librato.increment LIBRATO_PREFIX + subkey, sporadic: true, source: sqs_url(task_name)
      rescue StandardError => error
        Rails.logger.error error.message
      end
    end

    def self.log_error(error)
      Rails.logger.error error.message
      error.backtrace.each { |line| Rails.logger.error line }
    end

  end
end
