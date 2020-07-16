require 'rubygems/package'

namespace :geocoder_service do
  desc 'Download the Maxmind mmdb file for ip geocode service'
  task maxmind: :environment do
    FileUtils.mkdir_p(paths.tmp_dir)
    MMDBCloud.upload(paths.mmdb) if download_from_maxmind && extract_tar
    FileUtils.rm_rf(paths.tmp_dir)
  end

  def download_from_maxmind
    begin
      # raw_response true to download file in ~/tmp
      tempfile = RestClient::Request.execute( method: :get,
                                              url: paths.maxmind,
                                              raw_response: true)
      # File moving from ~/tmp to application tmp folders
      FileUtils.mv(tempfile.file.path, paths.storage)
      true
    rescue => e
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
    status
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
        maxmind: "#{Rails.application.config.shared_config[:geo_config][:maxmind]}"\
                 "?edition_id=GeoLite2-Country&"\
                 "license_key=#{Rails.configuration.geoip.license}&suffix=tar.gz"
    )
  end

end
