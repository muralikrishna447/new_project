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

      if env["PATH_INFO"] == '/joule'
        Rails.logger.info("Special proxy for /joule to /joule-crawler")
        proxy_env = env.deep_dup
        proxy_env["PATH_INFO"] = '/joule-crawler'
        return @app.call(proxy_env)

      else

        Rails.logger.info("Brombone request for path [#{env['REQUEST_URI']}]")

        # NOTE odd URI:
        # Should be like http://chefsteps.brombonesnapshots.com/www.chefsteps.com/activities/blini
        proxy_env = env.deep_dup
        proxy_env["HTTP_HOST"] = @backend_host
        proxy_env["REQUEST_PATH"] = proxy_env["REQUEST_URI"] = proxy_env["PATH_INFO"] = "/www.chefsteps.com#{proxy_env["PATH_INFO"]}"
        proxy_env["QUERY_STRING"] = ""

        response = perform_request(proxy_env)
        headers = response[1]

        # See explanatory comment in fresh_steps_proxy
        if headers.has_key?('cache-control') && headers['cache-control'].kind_of?(Array)
          headers['cache-control'] = headers['cache-control'][0]
        end

        # If we succeed or get a response indicating the requester already has a good cache, done.
        return response if [200, 304, 206].include? response[0]
        Rails.logger.info("Brombone request for path [#{env['REQUEST_URI']}] failed with code #{response[0]}- rendering locally")
      end
    end

    # Either not proxied or proxy failed
    @app.call(env)
  end

  def should_proxy?(env)
    request = Rack::Request.new(env)

    # We don't want to proxy assets, only pages, and fortunately none
    # of our pages end with extensions, but our assets do.
    return false if request.path =~ /\..{1,4}$/

    # Never proxy API!
    return false if request.path =~ /^\/api/

    # 11/3/15 For activities, running a split test where those whose slug starts with a-m just returns
    # the normal page to google, and n-z returns the snapshot. Right now only for google as we
    # don't think other crawlers are smart enough to run the javascript yet. The hope is that this
    # will help with including images in SERPs.
    #
    # 11/11/15 So this split test was going badly; the [a-m] pages seem to be missing
    # from the google index even though the are in the sitemap and fetch as googlebot
    # shows the fine. Reducing the split test to just the slugs starting with a
    # so we can wait awhile longer to see if they come back.
    #
    # 12/1/15 Well, even after waiting almost a month, avocado-puree and apartment-ribs etc
    # are still not in the SERPs. I have no idea why, Google claims it should be able to
    # handle our JS according to http://googlewebmastercentral.blogspot.com/2015/10/deprecating-our-ajax-crawling-scheme.html
    # Turning this off but leaving the code as a reminder to come back to it someday.
    # return false if env["HTTP_USER_AGENT"] =~ /(google)/ && request.path =~ /activities\/a/

    # Proxy if requester appears to be a crawler etc. This especially helps when someone
    # pastes one of our AJAX urls into facebook e.g.
    # (Presumably we could use only this test and not the _escaped_fragment_ one but that one
    # is so explicit no reason to ignore it.)
    result = env["HTTP_USER_AGENT"] =~ /(google|yahoo|bing|baidu|jeeves|facebook|Facebot|Twitterbot|linkedin|slack)/
    Rails.logger.info("User agent: #{env['HTTP_USER_AGENT']}, proxy: #{result ? 'yes' : 'no'}, path: #{env['REQUEST_URI']} query: #{env['QUERY_STRING']}")
    result
  end
end
