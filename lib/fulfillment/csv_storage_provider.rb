require 'aws-sdk'

module Fulfillment
  module CSVStorageProvider
    # Factory method to obtain a storage provider instance
    def self.provider(name)
      case name
      when 's3'
        Fulfillment::S3StorageProvider.new
      when 'file'
        Fulfillment::FileStorageProvider.new
      when 'stdout'
        Fulfillment::StandardOutputStorageProvider.new
      else
        raise "Unknown storage provider: #{name}"
      end
    end

    def save(_output, _params)
      raise 'save not implemented'
    end
  end

  # Stores CSV files in S3
  class S3StorageProvider
    include Fulfillment::CSVStorageProvider

    def read(params)
      validate_params(params)
      s3 = Aws::S3::Resource.new(region: params[:storage_s3_region])
      s3.bucket(params[:storage_s3_bucket]).object(params[:storage_filename]).get.body.read
    end

    def save(output, params)
      validate_params(params)
      raise 'type is a required param' unless params[:type]

      Rails.logger.info("S3 storage provider saving object with params #{params}")
      s3 = Aws::S3::Resource.new(region: params[:storage_s3_region])
      obj =
        s3
        .bucket(params[:storage_s3_bucket])
        .object("#{params[:type]}/#{params[:storage_filename]}")
      obj.put(body: output)
    end

    private

    def validate_params(params)
      raise 'storage_s3_bucket is a required param' unless params[:storage_s3_bucket]
      raise 'storage_s3_region is a required param' unless params[:storage_s3_region]
      raise 'storage_filename is a required param' unless params[:storage_filename]
    end
  end

  # Stores CSV files to local filesystem
  class FileStorageProvider
    include Fulfillment::CSVStorageProvider

    def read(params)
      validate_params(params)
      File.open(params[:storage_filename], 'r').read
    end

    def save(output, params)
      validate_params(params)
      raise 'type is a required param' unless params[:type]

      Rails.logger.info("File storage provider saving object with params #{params}")
      File.write(params[:storage_filename], output)
    end

    private

    def validate_params(params)
      raise 'storage_filename is a required param' unless params[:storage_filename]
    end
  end

  # Prints to standard output.
  class StandardOutputStorageProvider
    include Fulfillment::CSVStorageProvider

    def save(output, _params)
      puts output
    end
  end
end
