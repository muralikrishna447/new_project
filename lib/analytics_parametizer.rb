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
        # blog.chefsteps and store.chefsteps are considered external sites intentionally
        internal_refs = ['www.chefsteps.com', 'support.chefsteps.com', 'localhost']
        internal_refs.each do |ref|
          return false if referrer.include?(ref)
        end
      end

      true
    end

  end
end
