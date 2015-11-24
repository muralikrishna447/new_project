class AnalyticsCookies
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    utm_store = {}
    utm_params.each do |p|
      if req.params[p.to_s].present?
        puts "AnalyticsCookies - Setting #{p} to #{req.params[p.to_s]}"
        utm_store[p] = req.params[p.to_s]
      end
    end
    cookie_jar = ActionDispatch::Request.new(env).cookie_jar
    puts "Current Cookie #{cookie_jar[:utm]}\nSetting to #{utm_store.to_json}"
    cookie_jar[:utm] = utm_store.to_json if utm_store.present?
    @app.call(env)
  end

  def utm_params
    [:utm_campaign, :utm_name, :utm_source, :utm_medium, :utm_term, :utm_content]
  end
end
