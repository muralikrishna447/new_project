class BaseApplicationController < ActionController::Base
  before_filter :cors_set_access_control_headers, :record_uuid_in_new_relic, :log_current_user, :detect_country

  def record_uuid_in_new_relic
    ::NewRelic::Agent.add_custom_parameters({ request_id: request.uuid()})
  end

  def cors_set_access_control_headers
    # When XHR is made withCredentials=true, the browser requires that the allowed
    # origin not be set to * so we instead echo back the origin header to
    # achieve effectively the same behaviour.  This is restricted to requests
    # coming from "similar" origins (same domain, possibly different protocol)

    if request.headers['origin']
      begin
        origin_hostname = URI(request.headers['origin']).host
      rescue URI::InvalidURIError
        Rails.logger.info "[cors] Invalid origin #{request.headers['origin']} setting no CORS headers"
        return
      end

      headers['Access-Control-Allow-Origin'] = request.headers['origin']
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = '*, X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type, Authorization'
      headers['Access-Control-Max-Age'] = "1728000"

      # host header is not a URI as it doesn't include protocol but it does include a port
      host_hostname = request.headers['host'].split(':')[0]

      # chefsteps.dev is required for testing Facebook auth locally
      similar_origin = (origin_hostname == host_hostname || origin_hostname == 'chefsteps.dev')
      if similar_origin
        headers['Access-Control-Allow-Credentials'] = 'true'
      else
        Rails.logger.info "[cors] Not setting Access-Control-Allow-Credentials because origin #{request.headers['origin']} does not match host [#{request.headers['host']}]"
      end
    end
  end

  def detect_country
    unless cookies['cs_geo'].present?
      location = geolocate_ip
      #default to US so spree has something to work with
      location[:country] = 'US' if location[:country].blank?
      cookies['cs_geo'] = {
          :value => location.to_json,
          :domain => :all,
          :expires => Rails.configuration.geoip.cache_expiry.from_now
      }
    end
  end

  helper_method :facebook_app_id
  def facebook_app_id
    Rails.application.config.shared_config[:facebook][:app_id]
  end

  helper_method :facebook_secret
  def facebook_secret
    case Rails.env
    when "production"
      ENV["FACEBOOK_SECRET"]
    when "staging", "staging2"
      "1cb4115088bd42aed2dc6d9d11c82930"
    else
      "57601926064dbde72d57fedd0af8914f"
    end
  end

  def log_current_user
    logger.info("current_user id: #{current_user.nil? ? "anon" : current_user.id}")
  end

  before_filter :log_ga_client
  def log_ga_client
    if cookies[:_ga]
      logger.info "GA cookie value [#{cookies[:_ga]}] User [#{current_user ? current_user.id : nil}]"
    else
      logger.info "GA cookie not found"
    end
  end

    def null_location
      return {
        country: nil,
        latitude: nil,
        longitude: nil,
        city: nil,
        state: nil,
        zip: nil
      }
    end

    def geolocate_ip(ip_address = nil)
      t1 = Time.now
      metric_suffix = 'hit'
      location = null_location()
      ip_address = ip_address || get_ip_address
      logger.info("Geolocating IP: #{ip_address}")
      conf = Rails.configuration.geoip

      return location if ip_address == '127.0.0.1'

      begin
        key = "geocode-cache-#{ip_address}"
        location = Rails.cache.fetch(key, expires_in: conf.cache_expiry) do
          metric_suffix = 'miss'
          get_location_from_api(ip_address)
        end
      # TODO: we should narrow the scope of this rescue block, but not
      # sure all the ways in which Geoip2 can fail
      rescue Exception => e
        metric_suffix = 'fail'
        logger.error "Geocode failed: #{e}"
        logger.error e.backtrace.join("\n")
      end

      delta = Time.now - t1
      metric_name = "geocode.time.#{metric_suffix}"
      logger.info "#{metric_name} took #{delta}s"
      Librato.timing metric_name, delta * 1000
      Librato.increment "geocode.count.#{metric_suffix}"

      return location
    end

    protected

    class GeocodeError < StandardError
    end

    def get_location_from_api(ip_address)
      conn = Faraday.new(
        :url => "https://geoip.maxmind.com", request: { timeout: 2, open_timeout: 1}
      ) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conf = Rails.configuration.geoip
      conn.basic_auth(conf.user, conf.license)
      resp = conn.get "/geoip/v2.1/city/#{ip_address}"
      geocode = JSON.parse resp.body

      if geocode["error"] || !geocode["location"]
        raise GeocodeError.new("Geocoding failed for #{ip_address}")
      end

      country = (
        Utils.spelunk(geocode, ['country', 'iso_code']) ||
        Utils.spelunk(geocode, ['registered_country', 'iso_code'])
      )

      long_country = (
        Utils.spelunk(geocode, ['country', 'names', 'en']) ||
        Utils.spelunk(geocode, ['registered_country', 'names', 'en'])
      )

      if country == nil
        raise GeocodeError.new("No country info for #{ip_address}")
      end

      location = {
        country: country,
        long_country: long_country,
        latitude: geocode["location"]["latitude"],
        longitude: geocode["location"]["longitude"],
        city: Utils.spelunk(geocode, ["city", "names", "en"]),
        state: Utils.spelunk(geocode, ["subdivisions", 0, "iso_code"]),
        zip: Utils.spelunk(geocode, ["postal", "code"]),
      }
      return location
    end

  # This subscribe / track logic does not belong here but since it's curently
  # found in no less than three places throughout our code base this is the
  # least invasive place to store it
  def subscribe_and_track(user, optout, signup_method)
    email_list_signup(user, signup_method) unless optout
    mixpanel.alias(user.id, mixpanel_anonymous_id) if mixpanel_anonymous_id
    mixpanel.track(user.id, 'Signed Up', { signup_method: signup_method })
    Resque.enqueue(Forum, 'initial_user', Rails.application.config.shared_config[:bloom][:api_endpoint], user.id)

    ua = UserAcquisition.new(
      user_id: user.id,
      signup_method: signup_method,
    )
    ua.landing_page = request.referrer[0..5000] if request.referrer # truncate abnormally long URLs

    if cookies['utm']
      cookie = JSON.parse(cookies['utm'])
      ua.referrer = cookie['referrer'][0..5000] if cookie['referrer'] # truncate abnormally long URLs
      AnalyticsParametizer.utm_params.each { |param| cookie[param] ? ua[param] = cookie[param] : next }
    end

    if ua.save
      logger.info("[UserAcquisition] created an acquisition record for user #{user.id}")
    else
      logger.error("[UserAcquisition] failed to create an acquisition record for user #{user.id} #{ua.errors.inspect}")
    end

    Librato.increment 'user.signup', sporadic: true
  end

  def email_list_signup(user, source='unknown', listname=Rails.configuration.mailchimp[:list_id])
    begin
      long_country = geolocate_ip()[:long_country]

      # MMERGE2 is carefully chosen and is the same in prod and staging.  Ideally
      # it would be more descriptive but it was already set and existing systems
      # rely on it. It shows up as "Country" in the mailchimp segmentation settings
      # because of a mapping on their merge vars page.
      merge_vars = {
        NAME: user.name,
        SOURCE: source,
        MMERGE2: long_country,
        groupings: [
          {
            id: Rails.configuration.mailchimp[:email_preferences_group_id],
            groups: Rails.configuration.mailchimp[:email_preferences_group_default]
          }
        ]
      }
      logger.info "[mailchimp] Subscribing [#{user.email}] to list #{[listname]}, merge_vars: #{merge_vars}"

      Gibbon::API.lists.subscribe(
        id: listname,
        email: {email: user.email},
        merge_vars: merge_vars,
        double_optin: false,
        send_welcome: false
      )

    rescue Exception => e
      case Rails.env
      when "production", "staging", "staging2"
        logger.warn("[mailchimp] error: #{e.message}")
        unless e.message.include?("already subscribed to list")
          logger.error("[mailchimp] Failed to add user to mailchimp")
        end
      else
        logger.debug("[mailchimp] error, ignoring - did you set MAILCHIMP_API_KEY? Message: #{e.message}")
      end
    end
  end

    def get_ip_address
      (cookies[:cs_location] || request.ip)
    end

  helper_method :is_hosted_env
  def is_hosted_env
    if Rails.env.production? || Rails.env.staging? || Rails.env.staging2?
      true
    else
      false
    end
  end

  private
  def mixpanel
    @mixpanel ||= ChefstepsMixpanel.new
  end

  def mixpanel_anonymous_id
    begin
      JSON.parse(cookies["mp_#{mixpanel.instance_variable_get('@token')}_mixpanel"])['distinct_id']
    rescue
      id = request.session_options[:id]
      cookies["mp_#{mixpanel.instance_variable_get('@token')}_mixpanel"] = {distinct_id: id}.to_json
      id
    end
  end
end
