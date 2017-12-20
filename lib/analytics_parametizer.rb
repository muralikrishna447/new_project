class AnalyticsParametizer

  OUR_PROPERTY_SUBDOMAINS = ['support', 'www', 'store', 'shop']
  OUR_PROPERTY_FQDOMAINS = OUR_PROPERTY_SUBDOMAINS.map do |subdomain|
    "#{subdomain}.#{Rails.configuration.shared_config['chefsteps_endpoint']}"
  end

  class << self
    def utm_params
      ['utm_campaign', 'utm_source', 'utm_medium', 'utm_term', 'utm_content', 'gclid']
    end

    def cookie_value(url_params, cookies, referrer)
      cookie = Hash.new
      if reset_utm_cookie?(url_params, referrer)
        utm_params.each do |param_name|
          url_params[param_name].present? ? cookie[param_name] = url_params[param_name] : cookie.delete(param_name)
        end
        cookie[:referrer] = referrer unless referrer.blank?
        Rails.logger.info "[AnalyticsParametizer] Setting utm cookie to #{cookie.to_json} referrer:#{referrer}"
      else
        if cookies['utm'].present?
          begin
            cookie = JSON.parse(cookies['utm'])
          rescue JSON::ParserError => e
            Rails.logger.error "[AnalyticsParametizer] Unable to parse existing UTM Cookie #{cookies['utm']} -> #{e.message}"
            cookie = {}
          end
        end
        Rails.logger.info "[AnalyticsParametizer] Subsequent page load, cookie stays #{cookie.to_json} referrer:#{referrer}"
      end
      cookie.to_json
    end

    private

    def is_our_property?(url)
      OUR_PROPERTY_FQDOMAINS.any? do |fqd|
        url.include?(fqd)
      end
    end

    def reset_utm_cookie?(url_params, referrer)
      got_new_params = utm_params.any? do |param_name|
        url_params[param_name].present?
      end
      return true if got_new_params
      if referrer.blank?
        # Unfortunately this doesn't tell us anything so just keep the cookie
        # We could get more complex with this by placing a token in the session object
        return false
      else
        # if the referrer is not one of our properties then reset is a good idea
        return !is_our_property?(referrer)
      end
    end
  end
end
