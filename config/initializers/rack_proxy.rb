require "rack-proxy"

class FreshStepsProxy < Rack::Proxy
  EXACT = %w()
  # For awhile I had /browser-sync in this list, which was nice
  # because it got rid of rails errors and also made livereloading
  # work when proxying, but it also made regular page loads incredibly slow, I think because
  # browser-sync was pinging multiple times per second. Although without the proxy, rails returns 406 so
  # it is still doing work. Curious.
  PREFIX = %w(/gallery)

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
    # Add a <base> tag into the head so that relative URLs
    # are found at the proxy source, and set config on window.
    response[2][0].sub! "<head>", <<INJECT
      <head>
      <base href='http://#{env["HTTP_HOST"]}'>
INJECT

    # Have to recompute content-length or browser will truncate
    response[1]['content-length'] = response[2][0].length.to_s
    response

  end

  def rewrite_env(env)
    request = Rack::Request.new(env)

    if(
        EXACT.include?(request.path) ||
        EXACT.include?(request.path + "/") ||
        PREFIX.include?(request.path) ||
        PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")})
      env["HTTP_HOST"] = Rails.application.config.shared_config[:freshsteps_endpoint] || ENV["FRESHSTEPS_ENDPOINT"]
    end

    env
  end

end

Rails.application.middleware.insert_before ActionDispatch::Static, FreshStepsProxy
