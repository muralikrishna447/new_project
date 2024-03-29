require 'external_service_token_checker'
class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  def self.isWhitelisted(req)
    request_auth = req.env["HTTP_AUTHORIZATION"]
    is_authenticated_external_service = ExternalServiceTokenChecker.is_authenticated(request_auth)
    madore_ip = '66.171.190.210'
    market_ip = '199.231.242.34'
    # Requests are allowed if the return value is truthy
    is_authenticated_external_service || req.ip == madore_ip || req.ip == market_ip
  end

  ActiveSupport::Notifications.subscribe('track.rack_attack') do |name, start, finish, request_id, payload|
    req = payload[:request]
    unless isWhitelisted(req)
      Rails.logger.info("rack.attack throttled request path: #{req.path} ip: #{req.ip}")
      Librato.increment "api.throttled_requests", sporadic: true
    end
  end


   Rack::Attack.safelist('allow authorized external services and madore requests to go unthrottled') do |req|
     isWhitelisted(req)
   end

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (180rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 900, :period => 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle('logins/ip', :limit => 5, :period => 20.seconds) do |req|
    if req.path == '/api/v0/authenticate' && req.post?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  throttle("logins/email", :limit => 5, :period => 20.seconds) do |req|
    if req.path == '/api/v0/authenticate' && req.post?
      # return the email if present, nil otherwise
      req.params['email'].presence
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  self.throttled_response = lambda do |env|
   [ 429,  # status
     {},   # headers
     ['Jeezy Kableezy, too many requests, retry later!']] # body
  end
end
