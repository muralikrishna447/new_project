class BasicAuthEnforcer
  # NOT FOR PROD! Enforces basic auth except when the url path matches one of the supplied exceptions
  def initialize(app, exceptions = [])
    @app = app
    @exceptions = exceptions
    Rails.logger.info("Initializing with exceptions #{@exceptions}")

    @rack_basic_auth = Rack::Auth::Basic.new(@app, "staging") do |u,p|
      [u, p] == ['delve', 'howtochef22'] || [u, p] == ['guest', 'sphere']
    end
  end

  def call(env)
    if passthrough? env
      @app.call(env)
    else
      @rack_basic_auth.call(env)
    end
  end

  def passthrough?(env)
    path = env['REQUEST_PATH']

    @exceptions.each do |exception|
      if exception.match(path)
        Rails.logger.info("Request for path [#{path}] matches exception #{exception}")
        return true
      end
    end
    return false
  end
end
