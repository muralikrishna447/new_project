module CsSpree::Api::Countries

  def self.enabled_countries
    url_path = '/api/v1/cs_countries/enabled_countries'
    begin
      CacheExtensions::fetch_with_rescue('enabled_countries', 1.hour, 1.minute) do
        CsSpree.get_api(url_path)
      end
    rescue StandardError => e
      Rails.logger.error "Error in  CsSpree.get_api('#{url_path}') #{e}"
      DEFAULT_PRODUCT_GROUPS_BY_COUNTRY.fetch(up_iso2) do
        Rails.logger.error "No default Product Groups configured for #{up_iso2}"
      end
    end
  end

  def self.intl_enabled
    url_path = '/api/v1/cs_countries/intl_enabled'
    begin
      CacheExtensions::fetch_with_rescue('intl_enabled', 1.hour, 1.minute) do
        CsSpree.get_api(url_path)
      end
    rescue StandardError => e
      Rails.logger.error "Error in  CsSpree.get_api('#{url_path}') #{e}"
      DEFAULT_PRODUCT_GROUPS_BY_COUNTRY.fetch(up_iso2) do
        Rails.logger.error "No default Product Groups configured for #{up_iso2}"
      end
    end
  end

end