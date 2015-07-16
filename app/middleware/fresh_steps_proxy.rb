require "rack-proxy"

class FreshStepsProxy < Rack::Proxy
  # For awhile I had /browser-sync in this list, which was nice
  # because it got rid of rails errors and also made livereloading
  # work when proxying, but it also made regular page loads incredibly slow, I think because
  # browser-sync was pinging multiple times per second. Although without the proxy, rails returns 406 so
  # it is still doing work. Curious.
  #
  # TODO: I'm temporarily using /fs_gallery (and accepting that on the FS side) so we can have coexistence on prod
  # for a little while. Just change fs_gallery to gallery once everything is good.
  PREFIX = %w(/fs_gallery)

  def initialize(app)
    @app = app

    @backend_host = Rails.application.config.shared_config[:freshsteps_endpoint] || ENV["FRESHSTEPS_ENDPOINT"]
    @backend_protocol = "http"
    backend_uri = "#{@backend_protocol}://#{@backend_host}"
    Rails.logger.info("Initializing FreshStepsProxy with backend: #{backend_uri}")
    super({backend: backend_uri})
  end

  def call(env)
    if should_proxy?(env)
      Rails.logger.info("FreshStepsProxy request for path [#{env['REQUEST_URI']}]")
      env["HTTP_HOST"] = @backend_host
      perform_request(env)
    else
      @app.call(env)
    end
  end

  def should_proxy?(env)
    request = Rack::Request.new(env)

    # Don't proxy if this is google asking for HTML snapshot, that gets handled
    # in get_escaped_fragment_from_brombone
    leave_for_brombone = request.query_string.include?('_escaped_fragment_')
    prefix_match = PREFIX.include?(request.path) || PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")}

    !leave_for_brombone && prefix_match
  end
end
