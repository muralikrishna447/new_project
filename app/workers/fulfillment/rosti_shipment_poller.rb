require 'aws-sdk'

module Fulfillment
  module RostiShipmentPoller
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

    def self.perform(params)
      sqs = Aws::SQS::Client.new(region: aws_region)
      s3 = Aws::S3::Resource.new(region: aws_region)

      result = sqs.receive_message(queue_url: sqs_url)

      if result.messages.empty?
        Rails.logger.info('RostiShipmentPoller no messages received')
        return
      end

      result.messages.each do |received_message|
        sqs_message = JSON.parse(received_message.body)
        sns_message = JSON.parse(sqs_message.fetch('Message'))
        sns_message.fetch('Records').each do |s3_record|
          bucket = s3_record.fetch('s3').fetch('bucket').fetch('name')
          key = s3_record.fetch('s3').fetch('object').fetch('key')
          Rails.logger.info("RostiShipmentPoller received message for S3 shipments file #{bucket}:#{key}")

          # File should be in the shipments path and have .csv extension.
          # This queue receives notifications for all paths in the bucket,
          # so we ignore/delete any messages that don't match.
          unless key =~ /^shipments\/.+\.csv$/
            Rails.logger.info("RostiShipmentPoller S3 key does not match expected format, skipping: #{bucket}:#{key}")
            delete_message(sqs, received_message)
            next
          end

          # In prod the queue has a delivery delay. We check to make sure the
          # file still exists in case Rosti added the file then deleted it
          # shortly after. (It happens!)
          unless s3.bucket(bucket).object(key).exists?
            Rails.logger.info("RostiShipmentPoller S3 key does not exist, skipping: #{bucket}:#{key}")
            delete_message(sqs, received_message)
            next
          end

          Rails.logger.info("RostiShipmentPoller triggering import for file #{bucket}:#{key}")
          Fulfillment::RostiShipmentImporter.perform(
            complete_fulfillment: params[:complete_fulfillment],
            storage: 's3',
            storage_filename: key
          )
          delete_message(sqs, received_message)
        end
      end
    end

    def self.delete_message(sqs, message)
      sqs.delete_message(
        queue_url: sqs_url,
        receipt_handle: message.receipt_handle
      )
    end
  end
end
