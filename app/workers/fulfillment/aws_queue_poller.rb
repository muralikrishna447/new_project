require 'aws-sdk'
require 'retriable'

module Fulfillment
  class AwsQueuePoller

    extend Resque::Plugins::Lock

    TASK_POLLER = 'task-poller'

    LOGGING_NAMESPACE = (TASK_POLLER + '-' + Rails.env + '-').downcase.gsub(/\s+/, '-')

    QUEUE_LABEL = LOGGING_NAMESPACE

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
        rescue StandardError => error
          Rails.logger.error "Flushing librator tracker #{error.message}"
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
        # Rails.logger.error error.message
      end
    end

    def self.log_error(error)
      Rails.logger.error error.message
      error.backtrace.each { |line| Rails.logger.error line }
    end

  end
end
