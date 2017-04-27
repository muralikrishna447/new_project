require "rack-proxy"

class FreshStepsProxy < Rack::Proxy
  # For awhile I had /browser-sync in this list, which was nice
  # because it got rid of rails errors and also made livereloading
  # work when proxying, but it also made regular page loads incredibly slow, I think because
  # browser-sync was pinging multiple times per second. Although without the proxy, rails returns 406 so
  # it is still doing work. Curious.

  PREFIX = %w(/gallery /classes /logout /fs_pages /fs_activities /gift /admin/components /tpq /about /press /press-faq /joule /joule-overview /recommended /market /joule-split /orders /butchers)
  EXACT = %w(/ /sous-vide /grilling /indoor-barbecue /thanksgiving /holiday /premium /password-reset /chefsteps-debuts-joule /jobs /gifting /sso /sign-up /steak-by-joule /gifs /404 /forum-welcome /preorder-sweepstakes /preorder-sweepstakes-legal /components /lamarzocco-ultimate-espresso-kit /getting-started-with-joule /known-issues /food52 /Food52 /voice-control /cooking-challenge /equipment-we-love /opi-submissions /conversational-cooking /joule-one-million-meals)

  EXCLUDE = %w(/joule/warranty)
  SUFFIX = %w(/fork /notify_start_edit /notify_end_edit /as_json /the-egg-calculator /new)

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
      req = Rack::Request.new(env)
      cookie_value = AnalyticsParametizer.cookie_value(req.params, req.cookies, req.referrer)
      Rails.logger.info("FreshStepsProxy request for path [#{env['REQUEST_URI']}]")
      env["HTTP_HOST"] = @backend_host
      env["REQUEST_PATH"] = env["REQUEST_URI"] = env["PATH_INFO"] = "/index.html"
      status, headers, body = perform_request(env)
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

    # Don't proxy explicit requests for .json, those must be API type calls (like old index_as_json.json for mobile app)
    return false if request.path.end_with?('.json')

    prefix_match = PREFIX.include?(request.path) || PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")}
    exact_match = EXACT.include?(request.path)
    exclude_match = EXCLUDE.include?(request.path)

    # The logic below will only proxy GET requests with path /activities/:id
    activity_show_match = request.get? &&
                          request.path.starts_with?('/activities') &&
                          request.params['start_in_edit'].blank? &&
                          !SUFFIX.any?{|suffix| request.path.end_with?(suffix)}

    !exclude_match && (prefix_match || exact_match || activity_show_match)
  end
end
