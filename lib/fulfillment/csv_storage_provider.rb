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
      s3 = Aws::S3::Resource.new(region: 'us-east-1')
      obj = s3.bucket('chefsteps-jeremy').object("#{params[:type]}/orders-#{Time.now.utc.iso8601}.csv")
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
