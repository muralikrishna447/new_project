module CsSpree::Api::Countries

  def self.enabled_countries
    url_path = '/api/v1/cs_countries/enabled_countries'
    CacheExtensions::fetch_with_rescue('enabled_countries', 1.hour, 1.minute) do
      begin
        CsSpree.get_api(url_path)
      rescue StandardError => e
        Rails.logger.error "Error in  CsSpree.get_api('#{url_path}') #{e}"
        raise CacheExtensions::TransientFetchError,  "Error in CsSpree.get_api('#{url_path}') #{e.class.name} #{e.message}"
      end
    end
  end

  def self.intl_enabled
    url_path = '/api/v1/cs_countries/intl_enabled'
    CacheExtensions::fetch_with_rescue('intl_enabled', 1.hour, 1.minute) do
      begin
        CsSpree.get_api(url_path)
      rescue StandardError => e
        Rails.logger.error "Error in  CsSpree.get_api('#{url_path}') #{e}"
        raise CacheExtensions::TransientFetchError,  "Error in CsSpree.get_api('#{url_path}') #{e.class.name} #{e.message}"
      end
    end
  end

end
