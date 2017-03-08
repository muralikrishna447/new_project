require 'aws-sdk'
require 'retriable'

module Fulfillment
  class RostiShipmentPoller
    extend Resque::Plugins::Lock

    @queue = :RostiShipmentPoller

    def self.lock(_params)
      Fulfillment::CSVShipmentImporter::JOB_LOCK_KEY
    end

    def self.configure(params)
      @@aws_region = params[:aws_region]
      @@sqs_url = params[:sqs_url]
    end

    def self.aws_region
      @@aws_region
    end

    def self.sqs_url
      @@sqs_url
    end

    def self.perform(params = {})
      # Params hash keys are deserialized as strings coming out of Redis,
      # so we re-symbolize them here.
      job_params = params.deep_symbolize_keys

      sqs = sqs_client
      result = nil
      Retriable.retriable tries: 3 do
        result = sqs.receive_message(queue_url: sqs_url)
      end

      if result.messages.empty?
        Rails.logger.info('RostiShipmentPoller no messages received')
      else
        result.messages.each do |received_message|
          sqs_message = JSON.parse(received_message.body)
          sns_message = JSON.parse(sqs_message.fetch('Message'))
          sns_message.fetch('Records').each do |s3_record|
            process_s3_record(s3_record, job_params)
          end
          Retriable.retriable tries: 3 do
            sqs.delete_message(
              queue_url: sqs_url,
              receipt_handle: received_message.receipt_handle
            )
          end
        end
      end

      Librato.increment 'fulfillment.rosti.shipment-poller.success', sporadic: true
      Librato.tracker.flush
    end

    def self.process_s3_record(s3_record, params)
      bucket = s3_record.fetch('s3').fetch('bucket').fetch('name')
      key = s3_record.fetch('s3').fetch('object').fetch('key')
      Rails.logger.info("RostiShipmentPoller received message for S3 shipments file #{bucket}:#{key}")

      # File should be in the shipments path and have .csv extension.
      # This queue receives notifications for all paths in the bucket,
      # so we ignore/delete any messages that don't match.
      unless key =~ /^shipments\/.+\.csv$/
        Rails.logger.info("RostiShipmentPoller S3 key does not match expected format, skipping: #{bucket}:#{key}")
        return
      end

      # In prod the queue has a delivery delay. We check to make sure the
      # file still exists in case Rosti added the file then deleted it
      # shortly after. (It happens!)
      s3 = s3_client
      exists = false
      Retriable.retriable tries: 3 do
        exists = s3.bucket(bucket).object(key).exists?
      end
      unless exists
        Rails.logger.info("RostiShipmentPoller S3 key does not exist, skipping: #{bucket}:#{key}")
        return
      end

      Rails.logger.info("RostiShipmentPoller triggering import for file #{bucket}:#{key}")
      Fulfillment::RostiShipmentImporter.perform(
        complete_fulfillment: params[:complete_fulfillment],
        storage: 's3',
        storage_filename: key
      )
      Rails.logger.info("RostiShipmentPoller processing complete for file #{bucket}:#{key}")

      # Delete the shipments file from S3. The files are copied to an
      # archival location and the buckets are versioned to maintain history.
      # We delete objects after processing so it's easy to see what files
      # have completed processing versus pending.
      Retriable.retriable tries: 3 do
        s3.bucket(bucket).object(key).delete
      end
      Rails.logger.info("RostiShipmentPoller deleted S3 object #{bucket}:#{key}")
    end

    # Stub these out for unit tests.
    def self.sqs_client
      Aws::SQS::Client.new(region: aws_region)
    end

    def self.s3_client
      Aws::S3::Resource.new(region: aws_region)
    end
  end
end
