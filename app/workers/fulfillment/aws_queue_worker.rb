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
        task_name = sym_params.fetch(:task)


        librato_increment('started', task_name)

        Rails.logger.info { "AWSQueueWorker Called #{task_name} : #{sym_params.inspect}" }

        dispatch_task(task_name, sym_params[:message])

      rescue StandardError => error
        log_error error
        librato_increment('failure', task_name)
          raise # This is important because it will leave the message in the queue
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

    def self.dispatch_task(task_name, message_body)
      Rails.logger.info('AWSQueueWorker Dispatching ' + task_name.to_s + ' with ' + message_body.to_s)
      # Always perform tasks inline here, so if the task fails the messages
      # will not be deleted from the SQS queue. Going ASYNC will break that

      method_name = ('dispatch_' + task_name).to_sym

      # This will throw and cancel the message delivery if the method does not exist
      self.send(method_name, message_body)

    end

    # Task Handlers - dispatch_TASK_NAME
    # If this system becomes more used consider putting these in modules and mixing them
    # in dynamically
    def self.dispatch_submit_orders_to_rosti(message)

      Rails.logger.info('AWSQueueWorker dispatch_submit_orders_to_rosti( ' + message + ')')

      max_quantity = 1500
      max_quantity = 5 if Rails.env.development?
      max_quantity = 10 if Rails.env.staging? || Rails.env.staging2?
      notification_email = nil

      begin
        message_opts = JSON.parse(message, {symbolize_names: true})
        max_quantity = message_opts.fetch(:max_quantity, max_quantity)
        notification_email = message_opts.fetch(:notification_email, notification_email)
        Rails.logger.info("AWSQueueWorker dispatch_submit_orders_to_rosti max_quantity is #{max_quantity}")
      rescue StandardError => e
        Rails.logger.error("Error parsing dispatch_submit_orders_to_rosti message : " + message)
        Rails.logger.error(e.message)
      end


      inline = true
      Fulfillment::RostiOrderSubmitter.submit_orders_to_rosti( max_quantity, inline, notification_email )
    end

    def self.dispatch_submit_orders_to_fba(message)
      Rails.logger.info "AWSQueueWorker dispatch_submit_orders_to_fba with message #{message}"

      message_opts = JSON.parse(message, symbolize_names: true)
      Fulfillment::FbaOrderSubmitter.submit_orders_to_fba(
        sku: message_opts[:sku],
        perform_inline: true,
        max_quantity: message_opts[:max_quantity]
      )
    end

    def self.librato_increment(subkey, task_name)
      subkey = 'unknown' if subkey.nil?
      task_name = 'unknown' if task_name.nil?
      Rails.logger.info("Librato: #{LIBRATO_PREFIX} : #{subkey} : #{task_name}")
      begin
        Librato.increment LIBRATO_PREFIX + task_name + '.' + subkey, sporadic: true
      rescue StandardError => error
        log_error error
      end
    end

    def self.log_error(error)
      Rails.logger.error error.message
      error.backtrace.each { |line| Rails.logger.error line }
    end

  end
end
