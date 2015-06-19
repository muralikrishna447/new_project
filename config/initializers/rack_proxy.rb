require "rack-proxy"

class FreshStepsProxy < Rack::Proxy
  EXACT = %w()
  PREFIX = %w(/gallery /browser-sync)

  def initialize(app)
    @app = app
  end

  def call(env)
    original_host = env["HTTP_HOST"]
    rewrite_env(env)
    if env["HTTP_HOST"] != original_host
      rewrite_response(perform_request(env))
    else
      @app.call(env)
    end
  end

  def rewrite_response(response)
    response[2][0].sub! "<head>", "<head><base href=\'http://localhost:4000\'>"
    response
  end

  def rewrite_env(env)
    request = Rack::Request.new(env)

    if(
        EXACT.include?(request.path) ||
        EXACT.include?(request.path + "/") ||
        PREFIX.include?(request.path) ||
        PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")})
      env["HTTP_HOST"] = "localhost:4000"
    end

    env
  end

end

Rails.application.middleware.insert_before ActionDispatch::Static, FreshStepsProxy
