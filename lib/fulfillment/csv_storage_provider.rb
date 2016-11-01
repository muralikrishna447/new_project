require 'aws-sdk'

module Fulfillment
  module CSVStorageProvider
    def self.provider(name)
      case name
      when 's3'
        Fulfillment::S3StorageProvider.new
      when 'file'
        Fulfillment::FileStorageProvider.new
      else
        raise "Unknown storage provider: #{name}"
      end
    end

    def save(_output, _params)
      raise 'save not implemented'
    end
  end

  class S3StorageProvider
    include Fulfillment::CSVStorageProvider

    def save(output, params)
      raise 'storage_s3_bucket is a required param' unless params[:storage_s3_bucket]
      raise 'storage_s3_region is a required param' unless params[:storage_s3_region]
      s3 = Aws::S3::Resource.new(region: params[:storage_s3_region])
      obj =
        s3
        .bucket(params[:storage_s3_bucket])
        .object("#{params[:type]}/#{params[:type]}-#{Time.now.utc.iso8601}.csv")
      obj.put(body: output)
    end
  end

  class FileStorageProvider
    include Fulfillment::CSVStorageProvider

    def save(output, _params)
      File.write("orders-#{Time.now.utc.iso8601}.csv", output)
    end
  end
end
