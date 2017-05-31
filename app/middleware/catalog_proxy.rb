require "rack-proxy"

class CatalogProxy < Rack::Proxy

  PREFIX = %w(/cuts)

  def initialize(app)
    @app = app

    # @backend_host = Rails.application.config.shared_config[:freshsteps_endpoint] || ENV["FRESHSTEPS_ENDPOINT"]
    @backend_host = 'localhost:7777'

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
      env["REQUEST_PATH"] = env["REQUEST_URI"] = env["PATH_INFO"] = "#{req.fullpath.gsub('/cuts','')}"

      status, headers, body = perform_request(env)

      headers.delete "transfer-encoding"
      # The rack proxy mutates the http headers in a way which causes the rack
      # cache layer to crash.  This un-does the mutation.
      if headers.has_key?('cache-control') && headers['cache-control'].kind_of?(Array)
        headers['cache-control'] = headers['cache-control'][0]
      end

      utm_cookie = {
        :value => cookie_value,
        :domain => Rails.application.config.cookie_domain
      }
      Rack::Utils.set_cookie_header!(headers, 'utm', utm_cookie)
      [status, headers, body]
    else
      @app.call(env)
    end
  end

  def should_proxy?(env)
    request = Rack::Request.new(env)
    prefix_match = PREFIX.include?(request.path) || PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")}
    prefix_match
  end
end
