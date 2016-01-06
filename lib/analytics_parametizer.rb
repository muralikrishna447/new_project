class AnalyticsParametizer
  class << self
    def utm_params
      [:utm_campaign, :utm_name, :utm_source, :utm_medium, :utm_term, :utm_content, :utm_referrer, :utm_link]
    end

    def get_params(url_params, cookies)
      utm_store = {}
      # Load utm params and referrer from the cookies (or blank if no cookie)
      cookie_store = cookies['utm'].present? ? JSON.parse(cookies['utm']) : {}
      # If we have utm params present we're going to throw out all previous utm params so we don't merge differing params
      if params_present?(url_params)
        # Log previous values from the cookie if old utm params are set, so we can see the change
        Rails.logger.info "utm parameters from cookie: [#{cookie_store}]" if cookie_store.present?
        # Loop through the utm params and create a hash
        utm_params.each do |p|
          utm_store[p] = url_params[p.to_s] if url_params[p.to_s].present?
        end
        Rails.logger.info "utm parameters being set: [#{utm_store}]"
      else
        puts "testing here"
        puts cookie_store.inspect
        # Load values from the cookie so we don't lose our params
        utm_store = cookie_store
        Rails.logger.info "utm parameters not present current values: [#{utm_store}]"
      end
      utm_store
    end

    def params_present?(url_params)
      utm_params.any?{|p| url_params[p.to_s].present? }
    end

    def referer_is_chefsteps?(referer)
      (referer.include?('chefsteps.com') || referer.include?('localhost'))
    end

    def set_params(url_params, referer)
      # If there is a referer that isn't chefsteps merge in the new referer, this will let us always know the last non-chefsteps place they came from.
      url_params.merge!(referer: referer) if referer.present? && !referer_is_chefsteps?(referer)
      new_params = url_params.to_json
      Rails.logger.info "Setting cookie value to [#{new_params}]"
      return new_params
    end
  end
end
