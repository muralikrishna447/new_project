class MMDBCloud
  def self.download(storage_path)
    s3 = Aws::S3::Client.new(region: Rails.configuration.geoip.s3_region)
    begin
      s3.get_object(
          { bucket: Rails.configuration.geoip.bucket,
            key: Rails.configuration.geoip.s3_key },
          target: storage_path
      )
      true
    rescue => e
      Rails.logger.error "S3 Geocode download failed: #{e}"
      Rails.logger.error e.backtrace.join("\n")
      false
    end
  end

  def self.upload(path)
    s3 = Aws::S3::Resource.new(region: Rails.configuration.geoip.s3_region)
    bucket = s3.bucket(Rails.configuration.geoip.bucket)
    obj = bucket.object(Rails.configuration.geoip.s3_key)
    obj.upload_file(Pathname.new(path))
  end
end
