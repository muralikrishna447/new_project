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
    status, headers, body = @app.call(env)

    utm_store.each do |k,v|
      puts "AnalyticsCookies - Setting cookie #{k} to #{v}"
      Rack::Utils.set_cookie_header!(headers, k.to_s, {:value => v, :path => "/"})
    end

    [status, headers, body]
  end

  def utm_params
    [:utm_campaign, :utm_name, :utm_source, :utm_medium, :utm_term, :utm_content]
  end
end
