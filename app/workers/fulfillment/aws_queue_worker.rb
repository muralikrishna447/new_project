module Fulfillment
  class AwsQueueWorker

    LOGGING_NAMESPACE = 'com.chefsteps.awsqueue.worker.'+ Rails.env + '.'

    LOCK_QUEUE_NAME = (LOGGING_NAMESPACE + 'lock').to_sym

    LIBRATO_PREFIX = LOGGING_NAMESPACE

    extend Resque::Plugins::Lock

    @queue = LOCK_QUEUE_NAME

    def self.lock(_params)
      LOCK_QUEUE_NAME
    end

    def self.perform(params = {})
      sym_params = {}

      begin
        # Params hash keys are deserialized as strings coming out of Redis,
        # so we re-symbolize them here.
        sym_params = params.deep_symbolize_keys

        librato_increment('started', sym_params)

        Rails.logger.info { "AWSQueueWorker Called #{sym_params.inspect}" }

      rescue StandardError => error
        Rails.logger.error(error)
        librato_increment('failure', sym_params)
      else
        librato_increment('success', sym_params)
      ensure
        Librato.tracker.flush
      end
    end

    def self.librato_increment(subkey, sym_params)
      task_name = sym_params ? sym_params[:task_name] : :unknown_task_name
      Rails.logger.info("#{LIBRATO_PREFIX} : #{subkey} : #{task_name}")
      begin
        Librato.increment LIBRATO_PREFIX + subkey, sporadic: true
      rescue StandardError => error
        Rails.logger.error error
      end
    end

    def self.log_error(error)
      Rails.logger.error error.message
      error.backtrace.each { |line| Rails.logger.error line }
    end

  end
end
