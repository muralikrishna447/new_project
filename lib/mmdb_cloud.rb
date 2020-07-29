require 'retriable'

class MMDBCloud
  def self.download(storage_path)
    s3 = Aws::S3::Client.new(region: Rails.configuration.geoip.s3_region)
    begin
      Retriable.retriable tries: 3 do
        s3.get_object(
            { bucket: Rails.configuration.geoip.bucket,
              key: Rails.configuration.geoip.s3_key },
            target: storage_path
        )
      end
      Librato.increment "mmdb.s3.download.success"
      Rails.logger.info "S3 Geocode mmdb download success!!"
      true
    rescue => e
      Librato.increment "mmdb.s3.download.failed"
      Rails.logger.error "S3 Geocode mmdb download failed: #{e}"
      Rails.logger.error e.backtrace.join("\n")
      false
    end
  end

  def self.upload(path)
    s3 = Aws::S3::Resource.new(region: Rails.configuration.geoip.s3_region)
    bucket = s3.bucket(Rails.configuration.geoip.bucket)
    obj = bucket.object(Rails.configuration.geoip.s3_key)
    Retriable.retriable tries: 3 do
      obj.upload_file(Pathname.new(path))
    end
  rescue Exception => e
    Librato.increment "mmdb.s3.upload.failed"
    Rails.logger.error "S3 Geocode mmdb upoad failed: #{e}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def self.calculate_mmdb_file_age
    s3 = Aws::S3::Client.new(region: Rails.configuration.geoip.s3_region)
    begin
      latest_uploaded_file = Retriable.retriable tries: 3 do
        s3.head_object(
            {
                bucket: Rails.configuration.geoip.bucket,
                key: Rails.configuration.geoip.s3_key
            }
        )
      end
      age = Date.today.mjd - latest_uploaded_file.last_modified.to_date.mjd
      Librato.increment "mmdb.s3.last.modified.#{age}.days.ago" if age > 5
      Librato.increment ".s3.file.age.calculation.success"
      Rails.logger.info "S3 Geocode mmdb file is older than #{age} days"
    rescue Exception => e
      Librato.increment "mmdb.s3.file.age.calculation.failed"
      Rails.logger.error "S3 Geocode mmdb age calculation failed: #{e}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
