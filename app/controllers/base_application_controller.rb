require 'set'

class BaseApplicationController < ActionController::Base
  before_action :cors_set_access_control_headers, :record_uuid_in_new_relic, :log_current_user, :detect_country

  ALLOWED_ORIGINS = Set['www.chefsteps.com', 'shop.chefsteps.com',
                        'www.chocolateyshatner.com', 'shop.chocolateyshatner.com',
                        'www.vanillanimoy.com', 'shop.vanillanimoy.com',
                        'localhost', 'chefsteps.dev'] # chefsteps.dev is required for testing Facebook auth locally

  def record_uuid_in_new_relic
    ::NewRelic::Agent.add_custom_attributes({ request_id: request.uuid()})
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
      return if origin_hostname.blank?

      headers['Access-Control-Allow-Origin'] = request.headers['origin']
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = '*, X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type, Authorization'
      headers['Access-Control-Max-Age'] = "1728000"

      if allowed_origin?(origin_hostname)
        headers['Access-Control-Allow-Credentials'] = 'true'
      else
        Rails.logger.info "[cors] Not setting Access-Control-Allow-Credentials because origin #{origin_hostname} is not allowed"
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

  def detect_country_code
    return geolocate_ip[:country].presence || 'US' unless cookies['cs_geo'].present?

    JSON.parse(cookies['cs_geo'])['country']
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

  before_action :log_ga_client
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
        long_country: nil
      }
    end

    def dummy_location
      return {
          country: 'US',
          long_country: 'United States'
      }
    end

    def geolocate_ip(ip_address = nil)
      t1 = Time.now
      metric_suffix = 'hit'
      conf = Rails.configuration.geoip

      location = null_location()
      return location unless conf.is_configured

      ip_address = ip_address || get_ip_address
      logger.info("Geolocating IP: #{ip_address}")

      return dummy_location if ip_address == '127.0.0.1' || ip_address == '::1'

      begin
        location = GeoipService.get_geocode(ip_address)
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

  def email_list_add_to_group(email, grouping_id, groups)
    # Reject blank group names
    groups = groups.reject{ |name| name.blank? } if groups.kind_of?(Array)

    merge_vars = {
        groupings: [
            {
                id: grouping_id,
                groups: groups
            }
        ]
    }

    begin
      puts "Adding user: #{email} to interest groups"
      Gibbon::API.lists.update_member(
          id: Rails.configuration.mailchimp[:list_id],
          email: { email: email },
          merge_vars: merge_vars,
          replace_interests: false
      )
    rescue Exception => e
      puts "Error adding user: #{email}"
      puts "Error message: #{e.message}"
    end
  end

    protected

  # This subscribe / track logic does not belong here but since it's curently
  # found in no less than three places throughout our code base this is the
  # least invasive place to store it
  def subscribe_and_track(user, opt_in, signup_method)
    email_list_signup(user, signup_method) if opt_in
    Rails.logger.info("User Signed Up - #{user.id} signup_method: #{signup_method}")
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
        MMERGE2: long_country
      }
      logger.info "[mailchimp] Subscribing [#{user.email}] to list #{[listname]}, merge_vars: #{merge_vars}"

      double_opt_in = %w[AU DE].include? user.country_code
      Gibbon::API.lists.subscribe(
        id: listname,
        email: {email: user.email},
        merge_vars: merge_vars,
        double_optin: double_opt_in,
        send_welcome: false
      )
      user.update(marketing_mail_status: 'pending') if double_opt_in
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

  def unsubscribe_from_mailchimp(user)
    list_id = Rails.configuration.mailchimp[:list_id]
    begin
      Gibbon::API.lists.unsubscribe(:id => list_id, :email => {:email => user.email}, :delete_member => true)
    rescue Exception => e
      case Rails.env
      when "production", "staging", "staging2"
        logger.warn("[mailchimp] error: #{e.message}")
        unless e.message.include?("already subscribed to list")
          logger.error("[mailchimp] Failed to unsubscribe the user to mailchimp")
        end
      else
        logger.debug("[mailchimp] unsubscribe error, ignoring - did you set MAILCHIMP_API_KEY? Message: #{e.message}")
      end
    end
  end

  def subscribe_from_mailchimp(user)
    list_id = Rails.configuration.mailchimp[:list_id]
    begin
      Gibbon::API.lists.subscribe(:id => list_id, :email => {:email => user.email})
    rescue Exception => e
      case Rails.env
      when "production", "staging", "staging2"
        logger.warn("[mailchimp] error: #{e.message}")
        unless e.message.include?("already subscribed to list")
          logger.error("[mailchimp] Failed to subscribe the user to mailchimp")
        end
      else
        logger.debug("[mailchimp] subscribe error, ignoring - did you set MAILCHIMP_API_KEY? Message: #{e.message}")
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

  def allowed_origin?(origin)
    ALLOWED_ORIGINS.include?(origin)
  end
end
