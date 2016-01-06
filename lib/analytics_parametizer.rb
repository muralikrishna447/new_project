class AnalyticsParametizer
  class << self
    def utm_params
      [:utm_campaign, :utm_name, :utm_source, :utm_medium, :utm_term, :utm_content, :utm_referrer, :utm_link]
    end

    def get_params(url_params, cookies)
      utm_store = {}
      cookie_store = cookies['utm'] ? JSON.parse(cookies['utm']) : {}
      if params_present?(url_params)
        # Log previous values from the cookies
        Rails.logger.info "utm parameters from cookie: [#{cookie_store}]" if cookie_store.present?
        utm_params.each do |p|
          utm_store[p] = url_params[p.to_s] if url_params[p.to_s].present?
        end
        Rails.logger.info "utm parameters being set: [#{utm_store}]"
      else
        # Load values from the cookie
        utm_store = cookie_store
        Rails.logger.info "utm parameters not present current values: [#{utm_store}]"
      end
      utm_store
    end

    def params_present?(url_params)
      utm_params.any?{|p| url_params[p.to_s].present? }
    end

    def referer_is_chefsteps?(referer)
      referer.include?('chefsteps.com') || referer.include?('localhost')
    end

    def set_params(url_params, referer)
      url_params.merge!(referer: referer) unless referer_is_chefsteps?(referer)
      new_params = url_params.to_json
      Rails.logger.info "Setting cookie value to [#{new_params}]"
      return new_params
    end
  end
end
