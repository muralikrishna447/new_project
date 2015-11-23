require "rack-proxy"

class FreshStepsProxy < Rack::Proxy
  # For awhile I had /browser-sync in this list, which was nice
  # because it got rid of rails errors and also made livereloading
  # work when proxying, but it also made regular page loads incredibly slow, I think because
  # browser-sync was pinging multiple times per second. Although without the proxy, rails returns 406 so
  # it is still doing work. Curious.



  PREFIX = %w(/gallery /logout /fs_pages /fs_activities /gift /admin/components /tpq /about /press)
  EXACT = %w(/ /classes /sous-vide /grilling /indoor-barbecue /thanksgiving /premium /chefsteps-debuts-joule /joule /joule/ /joule/specs /password-reset)
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
      Rails.logger.info("FreshStepsProxy request for path [#{env['REQUEST_URI']}]")
      env["HTTP_HOST"] = @backend_host
      env["REQUEST_PATH"] = env["REQUEST_URI"] = env["PATH_INFO"] = "/index.html"
      response = perform_request(env)
      headers = response[1]
      # The rack proxy mutates the http headers in a way which causes the rack
      # cache layer to crash.  This un-does the mutation.
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

    # Don't proxy explicit requests for .json, those must be API type calls (like old index_as_json.json for mobile app)
    return false if request.path.end_with?('.json')

    # Don't proxy if this is google asking for HTML snapshot, that gets handled
    # in get_escaped_fragment_from_brombone
    leave_for_brombone = request.query_string.include?('_escaped_fragment_')
    prefix_match = PREFIX.include?(request.path) || PREFIX.any?{|prefix| request.path.starts_with?(prefix + "/")}
    exact_match = EXACT.include?(request.path)

    # The logic below will only proxy GET requests with path /activities/:id
    activity_show_match = request.get? &&
                          request.path.starts_with?('/activities') &&
                          request.params['start_in_edit'].blank? &&
                          !SUFFIX.any?{|suffix| request.path.end_with?(suffix)}

    !leave_for_brombone && (prefix_match || exact_match || activity_show_match)
  end
end
