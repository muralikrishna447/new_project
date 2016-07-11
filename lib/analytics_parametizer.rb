class AnalyticsParametizer
  class << self
    def utm_params
      ['utm_campaign', 'utm_source', 'utm_medium', 'utm_term', 'utm_content', 'gclid']
    end

    def cookie_value(url_params, cookies, referrer)
      cookie = {}

      if new_session?(referrer)
        # set / overwrite the utm cookie for the first page of a session
        utm_params.each do |p|
          url_params[p].present? ? cookie[p] = url_params[p] : cookie.delete(p)
        end
        referrer.nil? ? cookie.delete('referrer') : cookie[:referrer] = referrer
  
        Rails.logger.info "[AnalyticsParametizer] Setting utm cookie to #{cookie.inspect}"
      else
        cookie = cookies['utm'].present? ? JSON.parse(cookies['utm']) : {}
        Rails.logger.info "[AnalyticsParametizer] Subsequent page load, cookie stays #{cookie.inspect}"
      end

      cookie.to_json
    end

    private 

    def new_session?(referrer)
      unless referrer.nil?
        # blog.chefsteps is considered an external site intentionally
        internal_subdomains = ['support', 'www', 'store']
        internal_subdomains.each do |sub|
          return false if referrer.include?("#{sub}.#{Rails.configuration.shared_config['chefsteps_endpoint']}")
        end
      end

      true
    end

  end
end
