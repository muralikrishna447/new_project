class AnalyticsParametizer
  class << self
    def utm_params
      [:utm_campaign, :utm_name, :utm_source, :utm_medium, :utm_term, :utm_content, :utm_referrer, :utm_link]
    end

    def get_params(url_params)
      utm_store = {}
      utm_params.each do |p|
        utm_store[p] = url_params[p.to_s] if url_params[p.to_s].present?
      end
      Rails.logger.info "Grabbing analytics params [#{utm_store}]"
      utm_store
    end

    def set_params(url_params, referer)
      new_params = url_params.merge(referer: referer).to_json
      Rails.logger.info "Setting cookie value to [#{new_params}]"
      return new_params
    end
  end
end
