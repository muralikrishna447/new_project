module Fulfillment
  class AwsQueueWorker

    AWS_QUEUE_WORKER = 'aws-queue-worker'

    LOGGING_NAMESPACE = (AWS_QUEUE_WORKER + '-').downcase.gsub(/\s+/, '-')

    LIBRATO_PREFIX = LOGGING_NAMESPACE.tr('-', '.')

    def self.perform(params = {})
      sym_params = {}

      begin
        # Params hash keys are deserialized as strings coming out of Redis,
        # so we re-symbolize them here.
        sym_params = params.deep_symbolize_keys
        task_name = sym_params[:task]

        librato_increment('started', task_name)

        Rails.logger.info { "AWSQueueWorker Called #{task_name} : #{sym_params.inspect}" }

        dispatch_task(task_name, sym_params[:message])

      rescue StandardError => error
        Rails.logger.error(error)
        librato_increment('failure', task_name)
          raise # This is important because it will leave the message in the queue
      else
        librato_increment('success', task_name)
      ensure
        Librato.tracker.flush
      end
    end

    def self.dispatch_task(task_name, message_body)
      # Always perform tasks inline here, so if the task fails the messages
      # will not be deleted from the SQS queue. Going ASYNC will break that

      method_name = ('dispatch_' + task_name).to_sym

      # This will throw and cancel the message delivery if the method does not exist
      self.send(method_name, [message_body])

    end

    # Task Handlers - dispatch_TASK_NAME
    # If this system becomes more used consider putting these in modules and mixing them
    # in dynamically
    def self.dispatch_submit_orders_to_rosti(message)
      max_quantity = 1500 # Consider pull this from the message, but let's leave that for now
      max_quantity = 5 if Rails.env.development?
      max_quantity = 10 if Rails.env.staging? || Rails.env.staging2?
      inline = true
      Fulfillment::RostiOrderSubmitter.submit_orders_to_rosti( max_quantity, inline )
    end


    def self.librato_increment(subkey, task_name)
      Rails.logger.info("#{LIBRATO_PREFIX} : #{subkey} : #{task_name}")
      begin
        Librato.increment LIBRATO_PREFIX + task_name + '.' + subkey, sporadic: true
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
