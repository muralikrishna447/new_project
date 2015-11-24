class AnalyticsCookies
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      req = Rack::Request.new(env)
      utm_store = {}
      utm_params.each do |p|
        if req.params[p.to_s].present?
          utm_store[p] = req.params[p.to_s]
        end
      end
      if utm_store.present?
        cookie_jar = ActionDispatch::Request.new(env).cookie_jar
        Rails.logger.info "AnalyticsCookies - Current Cookie #{cookie_jar[:utm]}\nSetting to #{utm_store.to_json}"
        cookie_jar[:utm] = utm_store.to_json.to_s
      end
    rescue => e
      Rails.logger.error "AnalyticsCookies - Something went wrong #{e}"
    end
    @app.call(env)
  end

  def utm_params
    [:utm_campaign, :utm_name, :utm_source, :utm_medium, :utm_term, :utm_content]
  end
end
