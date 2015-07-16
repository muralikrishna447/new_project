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
  end

  def call(env)
    Rails.logger.info("FreshStepsProxy request for path [#{env['REQUEST_URI']}]")
    original_host = env["HTTP_HOST"]
    rewrite_env(env)
    if env["HTTP_HOST"] != original_host
      rewrite_response(perform_request(env), env)
    else
      @app.call(env)
    end
  end

  def rewrite_response(response, env)
    response
  end

  def rewrite_env(env)
    request = Rack::Request.new(env)

    # Don't proxy if this is google asking for HTML snapshot, that gets handled
    # in get_escaped_fragment_from_brombone
    if ! request.query_string.include?('_escaped_fragment_')
      if(
          PREFIX.include?(request.path) ||
          PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")})
        env["HTTP_HOST"] = Rails.application.config.shared_config[:freshsteps_endpoint] || ENV["FRESHSTEPS_ENDPOINT"]

        # I don't actually know if I need all 3 of these
        env["REQUEST_PATH"] = env["REQUEST_URI"] = env["PATH_INFO"] = "/index.html"

        # S3 assets are not https
        env["rack.url_scheme"] = "http"

        Rails.logger.info("FreshStepsProxy proxied [#{env['HTTP_HOST']}#{env['REQUEST_URI']}]")

      end
    end

    env
  end

end

Rails.application.middleware.insert_before ActionDispatch::Static, FreshStepsProxy
