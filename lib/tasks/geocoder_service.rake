require 'rubygems/package'

namespace :geocoder_service do
  desc 'Download the Maxmind mmdb file for ip geocode service'
  task update_maxmind_db: :environment do
    FileUtils.mkdir_p(paths.tmp_dir)
    MMDBCloud.upload(paths.mmdb) if download_from_maxmind && extract_tar
    FileUtils.rm_rf(paths.tmp_dir)
    Librato.tracker.flush
  end

  desc 'Age calculation for last mmdb uploaded file to s3'
  task s3_maxmind_db_age_calculator: :environment do
    MMDBCloud.calculate_mmdb_file_age
    Librato.tracker.flush
  end

  def download_from_maxmind
    begin
      # raw_response true to download file in ~/tmp
      tempfile = RestClient::Request.execute( method: :get,
                                              url: paths.maxmind,
                                              raw_response: true)
      # File moving from ~/tmp to application tmp folders
      FileUtils.mv(tempfile.file.path, paths.storage)
      Librato.increment "mmdb.maxmind.download.success"
      Rails.logger.info "Geocode mmdb Download from Maxmind success"
      true
    rescue => e
      Librato.increment "mmdb.maxmind.download.failed"
      Rails.logger.error "Geocode mmdb Download from Maxmind failed : #{e}"
      Rails.logger.error e.backtrace.join("\n")
      false
    end
  end

  def extract_tar
    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(paths.storage))
    return false unless tar_extract

    status = false
    tar_extract.each do |entry|
      status = write_file(entry)
      break if status
    end
    tar_extract.close
    raise StandardError.new('File Not found') unless status

    Rails.logger.info "mmdb extracted successfully"
    Librato.increment "mmdb.extraction.success"
    status
  rescue Exception => e
    Rails.logger.error "mmdb extraction failed: #{e}"
    Librato.increment "mmdb.extraction.failed"
    false
  end

  def write_file(entry)
    return false unless entry.file? && entry.full_name.ends_with?('.mmdb')

    File.open(paths.mmdb, 'wb') { |f| f.write(entry.read) }
    true
  end

  def paths
    OpenStruct.new(
        tmp_dir: "#{Rails.root}/tmp/maxmind",
        storage: "#{Rails.root}/tmp/maxmind/country.tar.gz",
        mmdb: "#{Rails.root}/tmp/maxmind/country.mmdb",
        maxmind: "#{Rails.configuration.geoip.maxmind}"\
                 "?edition_id=GeoLite2-Country&"\
                 "license_key=#{Rails.configuration.geoip.license}&suffix=tar.gz"
    )
  end

end
