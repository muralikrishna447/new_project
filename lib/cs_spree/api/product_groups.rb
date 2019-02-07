module CsSpree::Api::ProductGroups

  def self.product_groups_cache_key(up_iso2)
    "cs_spree_api_product_groups_#{up_iso2}"
  end

  def self.for_country(iso2_country_code)
    up_iso2 = iso2_country_code.upcase
    url_path = "/api/v1/cs_countries/#{up_iso2}/cs_product_groups"
    CacheExtensions::fetch_with_rescue(product_groups_cache_key(up_iso2), 1.hour, 1.minute) do
      begin
       CsSpree.get_api(url_path)
      rescue StandardError => e
        Rails.logger.error "Error in  CsSpree.get_api('#{url_path}') #{e}"
        raise CacheExtensions::TransientFetchError,  "Error in CsSpree.get_api('#{url_path}') #{e.class.name} #{e.message}"
      end
    end
  end
end