require 'external_service_token_checker'

module Api
  class BaseController < BaseApplicationController
    instrument_action :all

    skip_before_filter :verify_authenticity_token
    # before_filter :cors_set_access_control_headers

    rescue_from Exception do |exception|
      logger.error exception
      logger.error exception.backtrace
      render json: {status: 500, message: 'Server error'}, status: 500
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Origin, Content-Type, Accept, Authorization, Token, cs-referer'
      headers['Access-Control-Max-Age'] = "1728000"
      if request.method == 'OPTIONS'
        render :text => '', :content_type => 'text/plain'
      end
    end

    def options
      render :text => '', :content_type => 'text/plain'
    end

    def default_serializer_options
      {root: false}
    end

    def authenticate_active_admin_user!
      # Remove current_user logic when we move to full token
      if current_user
        unless current_user.role?(:contractor)
          render_api_response(401, {message: 'Unauthorized'})
          return
        end
      else
        begin
          ensure_authorized
          user = User.find @user_id_from_token
          unless user.admin
            render_api_response(401, {message: 'Unauthorized'})
            return
          end
        rescue Exception => e
          logger.error e
          logger.error e.backtrace.join("\n")
        end
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
      location = null_location()
      ip_address = ip_address || get_ip_address
      logger.info("Geolocating IP: #{ip_address}")

      return location if ip_address == '127.0.0.1'

      begin
        location = get_location_from_api(ip_address)
      # TODO: we should narrow the scope of this rescue block, but not
      # sure all the ways in which Geoip2 can fail
      rescue Exception => e
        logger.error e
        logger.error e.backtrace.join("\n")
      end
      return location
    end

    protected

    class GeocodeError < StandardError
    end

    def get_location_from_api(ip_address)
      conn = Faraday.new(
        :url => "https://geoip.maxmind.com", request: { timeout: 3 }
      ) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conn.basic_auth('106517', 'v6DjqPqzPsNL')
      resp = conn.get "/geoip/v2.1/city/#{ip_address}"
      geocode = JSON.parse resp.body

      if geocode["error"] || !geocode["location"]
        raise GeocodeError("Geocoding failed for #{ip_address}")
      end

      location = {
        country: geocode["country"]["iso_code"],
        latitude: geocode["location"]["latitude"],
        longitude: geocode["location"]["longitude"],
        city: geocode["city"]["names"]["en"],
        state: geocode["subdivisions"].first()["iso_code"],
        zip: geocode["postal"]["code"],
      }
      return location
    end

    def get_ip_address
      (cookies[:cs_location] || request.ip)
    end

    class AuthorizationError < StandardError
    end

    def get_valid_actor_address
      unless request.authorization()
        raise AuthorizationError("No Authorization header set")
      end

      token = request.authorization().split(' ').last


      token = AuthToken.from_string(token)
      aa = ActorAddress.find_for_token(token)
      unless aa
        logger.info "Not ActorAddress found for token #{token}"
        return
      end

      logger.debug "Found actor address: [#{aa.inspect}]"
      unless aa.valid_token?(token)
        logger.info "Invalid token #{token.inspect}"
        return
      end

      return aa
    end

    def ensure_authorized_or_anonymous
      if not request.authorization()
        logger.debug "No Authorization header set, continuing as anonymous"
        return
      end
      ensure_authorized()
    end

    def ensure_authorized(render_response = true)
      begin
        if not request.authorization()
          logger.info "Authorization token not set"
          render_api_response(401, {message: 'Unauthenticated'}) if render_response
          return
        end

        aa = get_valid_actor_address()
        if not aa or aa.actor_type != 'User'
          render_unauthorized if render_response
          return
        end
        @user_id_from_token = aa.actor_id
        @actor_address_from_token = aa
      rescue Exception => e
        logger.error e
        logger.error e.backtrace.join("\n")
        render_unauthorized if render_response
      end
    end

    def ensure_circulator_user
      circulator_id = params[:id]
      unless params[:id]
        render_api_response 400, {message: "Must specify id"}
        return false
      end
      @circulator = Circulator.where(circulator_id: params[:id]).first

      if @circulator.nil?
        render_api_response 403, {message: 'Circulator not found'}
        return false
      end

      @circulator_user = CirculatorUser.find_by_circulator_and_user @circulator, @user_id_from_token
      if @circulator_user.nil?
        logger.error "Unauthorized access to circulator [#{circulator_id}] by user [#{@user_id_from_token}]"
        render_unauthorized
        return false
      end
      return true
    end

    def ensure_circulator_owner
      # Dance required to prevent double-renders
      unless ensure_circulator_user
        unless performed?
          return render_unauthorized
        else
          return
        end
      end

      unless (@circulator_user && @circulator_user.owner)
        return render_unauthorized
      end
    end

    def current_api_user
      # @user_id_from_token is validated against actor address table
      User.find @user_id_from_token
    end

    # Still used by messaging service stuff
    def valid_token?(token, restrict_to = nil)
      key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
      decoded = JSON::JWT.decode(token, key)
      verified = JSON::JWT.decode(decoded.to_s, key.to_s)
      time_now = (Time.now.to_f * 1000).to_i
      if verified[:exp] && verified[:exp] <= time_now
        return false
      elsif verified['restrictTo'] && verified['restrictTo'] != restrict_to
        return false
      else
        @user_id_from_token = verified[:user][:id]
        return verified
      end
    end

    def ensure_authorized_service
      request_auth = request.authorization()
      is_authorized = ExternalServiceTokenChecker.is_authorized(request_auth)
      if is_authorized
        return true
      else
        render_unauthorized
      end
    end

    def render_api_response status, contents = {}, each_serializer = nil

      if contents.kind_of?(Array)
        # This gets the JSON structure but doesn't convert to string yet
        contents = ActiveModel::ArraySerializer.new(contents, each_serializer: each_serializer).as_json
        # Wrap array in an object so we can add the request_id and status
        contents = {results: contents}
      end

      contents[:request_id] = request.uuid()
      contents[:status] = status

      logger.info("API Response: #{contents.inspect}")
      render json: contents, status: status
    end

    def render_unauthorized
      render_api_response(403, {message: 'Unauthorized.'})
    end
  end
end
