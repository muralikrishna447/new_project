require "rack-proxy"

class CatalogProxy < Rack::Proxy

  PREFIX = %w(/cuts)
  HEADERS_TO_FORWARD = %w(
    Content-Type
    Content-Length
    Content-Encoding
    Location
  )

  def initialize(app)
    @app = app

    @backend_host = Rails.application.config.shared_config[:catalog_endpoint] || ENV["CATALOG_ENDPOINT"]
    puts "BACKEND_HOST: #{@backend_host}"
    @backend_protocol = "http"
    backend_uri = "#{@backend_protocol}://#{@backend_host}"
    Rails.logger.info("Initializing CatalogProxy with backend: #{backend_uri}")
    super({backend: backend_uri})
  end

  def call(env)
    if should_proxy?(env)

      req = Rack::Request.new(env)
      cookie_value = AnalyticsParametizer.cookie_value(req.params, req.cookies, req.referrer)
      Rails.logger.info("CatalogProxy request for path [#{env['REQUEST_URI']}]")
      env["HTTP_HOST"] = @backend_host

      env["REQUEST_PATH"] = env["REQUEST_URI"] = env["PATH_INFO"]

      status, headers, body = perform_request(env)

      [status, headers_from_response(headers), body]
    else
      @app.call(env)
    end
  end

  def should_proxy?(env)
    request = Rack::Request.new(env)
    prefix_match = PREFIX.include?(request.path) || PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")}
    prefix_match
  end

  def headers_from_response(headers)
    HEADERS_TO_FORWARD.each_with_object(Rack::Utils::HeaderHash.new) do |header, hash|
      value = headers[header]
      hash[header] = value if value
    end
  end
end
