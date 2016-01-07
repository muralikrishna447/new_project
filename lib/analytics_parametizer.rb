class AnalyticsParametizer
  class << self
    def utm_params
      [:utm_campaign, :utm_source, :utm_medium, :utm_term, :utm_content]
    end

    def cookie_value(url_params, cookies, referrer)
      new_cookie = {}
      # Load utm params and referrer from the cookies (or blank if no cookie)
      old_cookie = utm_cookie(cookies)
      # Log previous values from the cookie if old utm params are set, so we can see the change
      Rails.logger.info "utm parameters from cookie: [#{old_cookie}]" if old_cookie.present?
      # If we have utm params present we're going to throw out all previous utm params so we don't merge differing params
      if params_present?(url_params) || new_referrer(referrer, old_cookie)
        unless referrer_is_chefsteps?(referrer)
          new_cookie = utm_values(url_params)
          new_cookie.merge!(referrer: referrer)
        else
          Rails.logger.error "utm referrer coming from ChefSteps.com with new utm values: [#{new_cookie}] setting back to old values [#{old_cookie}]"
          new_cookie = old_cookie
        end
      else
        # Load values from the cookie so we don't lose our params
        new_cookie = old_cookie
        Rails.logger.info "utm parameters not present current values: [#{new_cookie}]"
      end
      Rails.logger.info "new_cookie value: [#{new_cookie}]"
      # Convert to the json to throw in the cookie
      new_cookie_json = new_cookie.to_json
      Rails.logger.info "Setting cookie value to [#{new_cookie_json}]"
      new_cookie_json
    end

    def utm_cookie(cookies)
      cookies['utm'].present? ? JSON.parse(cookies['utm']) : {}
    end

    def new_referrer(referrer, old_cookie)
      (referrer.present? && referrer != old_cookie['referrer'] && !referrer_is_chefsteps?(referrer))
    end

    def utm_values(url_params)
      # Loop through the utm params and create a hash
      values = {}
      utm_params.each do |p|
        values[p] = url_params[p.to_s] if url_params[p.to_s].present?
      end
      Rails.logger.info "utm parameters being set: [#{values}]"
      values
    end

    def params_present?(url_params)
      utm_params.any?{|p| url_params[p.to_s].present? }
    end

    def referrer_is_chefsteps?(referrer)
      # If they don't have a referrer they are coming from somewhere outside
      # Locking to www so that blog and store.chefsteps.com are tracked as external to the site
      referrer.present? && (referrer.include?('www.chefsteps.com') || referrer.include?('localhost') || referrer.include?('http://chefsteps.com') || referrer.include?('https://chefsteps.com'))
    end
  end
end
