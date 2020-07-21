class GeoIPService
  class GeocodeError < StandardError
    def message
      'GeoIP database not loaded'
    end
  end

  @@data = nil

  def self.initiate
    # mmdb File download from S3 and store inside tmp folder
    path = "#{Rails.root}/tmp/maxmind"
    FileUtils.mkdir_p(path)
    if MMDBCloud.download("#{path}/maxmind-country.mmdb")
      @@data = MaxMind::DB.new("#{path}/maxmind-country.mmdb", mode: MaxMind::DB::MODE_MEMORY)
      FileUtils.rm_rf(path)
    end
  end

  def self.get_geocode(ip_address)
    raise GeocodeError unless @@data

    object = @@data.get(ip_address)['country']
    {
        country: object.dig('iso_code'),
        long_country: object.dig('names', 'en')
    }
  end
end
