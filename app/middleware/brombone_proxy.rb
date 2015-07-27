require "rack-proxy"

# This proxies our static HTML snapshots from brombone.com whenever the requester is a spider
# that isn't going to run its own javascript.
#
# Read this for more info: http://www.brombone.com/documentation/

class BromboneProxy < Rack::Proxy
  def initialize(app)
    @app = app
    @backend_host = "chefsteps.brombonesnapshots.com"
    @backend_protocol = "http"
    backend_uri = "#{@backend_protocol}://#{@backend_host}"
    Rails.logger.info("Initializing Brombone proxy with backend: #{backend_uri}")
    super({backend: backend_uri})
  end

  def call(env)
    if should_proxy?(env)
      Rails.logger.info("Brombone request for path [#{env['REQUEST_URI']}]")

      # NOTE odd URI:
      # Should be like http://chefsteps.brombonesnapshots.com/www.chefsteps.com/activities/blini
      env["HTTP_HOST"] = @backend_host
      env["REQUEST_PATH"] = env["REQUEST_URI"] = env["PATH_INFO"] = "/www.chefsteps.com#{env["PATH_INFO"]}"
      env["QUERY_STRING"] = ""

      response = perform_request(env)
      headers = response[1]

      # See explanatory comment in fresh_steps_proxy
      if headers.has_key?('cache-control') && headers['cache-control'].kind_of?(Array)
        headers['cache-control'] = headers['cache-control'][0]
      end
      response
    else
      @app.call(env)
    end
  end

  def should_proxy?(env)
    request = Rack::Request.new(env)

    # We don't want to proxy assets, only pages, and fortunately none
    # of our pages end with extensions, but our assets do.
    return false if request.path =~ /\..{1,4}$/

    # Proxy if requester is explicitly asking for an HTML snapshot
    # (https://developers.google.com/webmasters/ajax-crawling/docs/specification)
    return true if request.query_string.include?('_escaped_fragment_')

    # Proxy if requester appears to be a crawler etc. This especially helps when someone
    # pastes one of our AJAX urls into facebook e.g.
    # (Presumably we could use only this test and not the _escaped_fragment_ one but that one
    # is so explicit no reason to ignore it.)
    env["HTTP_USER_AGENT"] =~ /(google|yahoo|bing|baidu|jeeves|facebook|twitter|linkedin)/
  end
end
