require "rack-proxy"

class FreshStepsProxy < Rack::Proxy
  EXACT = %w()
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
    original_host = env["HTTP_HOST"]
    rewrite_env(env)
    if env["HTTP_HOST"] != original_host
      rewrite_response(perform_request(env), env)
    else
      @app.call(env)
    end
  end

  def rewrite_response(response, env)
    status, headers, body = response

    # Add a <base> tag into the head so that relative URLs
    # are found at the proxy source, and set config on window.
    body[0].sub "<head>", <<INJECT
      <head>
      <base href='http://#{env["HTTP_HOST"]}'>
      <script type="text/javascript">
        window.csConfig = #{Rails.application.config.shared_config.to_json};
      </script>
INJECT

    # Have to recompute content-length or browser will truncate
    headers['content-length'] = body[0].bytesize.to_s

    response
  end

  def rewrite_env(env)
    request = Rack::Request.new(env)

    # Don't proxy if this is google asking for HTML snapshot, that gets handled
    # in get_escaped_fragment_from_brombone
    if ! request.query_string.include?('_escaped_fragment_')
      if(
          EXACT.include?(request.path) ||
          EXACT.include?(request.path + "/") ||
          PREFIX.include?(request.path) ||
          PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")})
        env["HTTP_HOST"] = Rails.application.config.shared_config[:freshsteps_endpoint] || ENV["FRESHSTEPS_ENDPOINT"]
      end
    end

    env
  end

end

Rails.application.middleware.insert_before ActionDispatch::Static, FreshStepsProxy
