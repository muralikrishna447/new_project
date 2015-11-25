class BaseApplicationController < ActionController::Base
  before_filter :cors_set_access_control_headers, :record_uuid_in_new_relic, :log_current_user

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


  def catch_and_retry(retry_count)
    begin
      yield
    rescue => error
      retry_count -= 1
      if retry_count > 0
        Rails.logger.error("Got error #{error} Retrying #{retry_count} more times")
        retry
      else
        Rails.logger.error("Received Error #{error}")
      end
    end
  end

  def cache_for_production(cache_name, expiration)
    result = nil
    if Rails.env.production?
      result = Rails.cache.fetch(cache_name, expires_in: expiration) do
        yield
      end
    else
      result = yield
    end
    return result
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

  def email_list_signup(name, email, source='unknown', listname=Rails.configuration.mailchimp[:list_id])
    begin
      Gibbon::API.lists.subscribe(
        id: listname,
        email: {email: email},
        merge_vars: {NAME: name, SOURCE: source},
        double_optin: false,
        send_welcome: false
      )

    rescue Exception => e
      case Rails.env
      when "production", "staging", "staging2"
        logger.warn("MailChimp error: #{e.message}")
        unless e.message.include?("already subscribed to list")
          logger.error("Failed to add user to mailchimp")
        end
      else
        logger.debug("MailChimp error, ignoring - did you set MAILCHIMP_API_KEY? Message: #{e.message}")
      end
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
