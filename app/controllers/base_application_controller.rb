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
      headers['Access-Control-Allow-Origin'] = request.headers['origin']
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = '*, X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type, Authorization'
      headers['Access-Control-Max-Age'] = "1728000"

      origin_hostname = URI(request.headers['origin']).host
      # host header is not a URI as it doesn't include protocol but it does include a port
      host_hostname = request.headers['host'].split(':')[0]

      similar_origin = (origin_hostname == host_hostname)
      if similar_origin
        headers['Access-Control-Allow-Credentials'] = 'true'
      else
        Rails.logger.info "[cors] Not setting Access-Control-Allow-Credentials because origin #{request.headers['origin']} does not match host [#{request.headers['host']}]"
      end
    end
  end

  def log_current_user
    logger.info("current_user id: #{current_user.nil? ? "anon" : current_user.id}")
  end
end
