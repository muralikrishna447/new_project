class AnalyticsCookies
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    referrer = req.referer
    utm_store = {}
    utm_params.each do |p|
      if req.params[p.to_s].present?
        utm_store[p] = req.params[p.to_s]
      end
    end
    status, headers, body = @app.call(env)
    unless utm_store.blank?
      utm_store[:utm_link] = referrer
      Rails.logger.info "AnalyticsCookies - Setting to [#{utm_store.to_json}]"
      Rack::Utils.set_cookie_header!(headers, 'utm', utm_store.to_json.to_s)
    end

    return [status, headers, body]
  end

  def utm_params
    [:utm_campaign, :utm_name, :utm_source, :utm_medium, :utm_term, :utm_content, :utm_referrer, :utm_link]
  end
end
