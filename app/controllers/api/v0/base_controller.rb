module Api
  module V0
    class BaseController < BaseApplicationController
      skip_before_filter :verify_authenticity_token
      # before_filter :cors_set_access_control_headers

      # rescue_from Exception do |exception|
      #   logger.error exception
      #   logger.error exception.backtrace
      #   render json: {status: 500, message: 'Server error'}, status: 500
      # end

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

      def email_list_signup(name, email, source='unknown', listname='a61ebdcaa6')
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
            logger.error("MailChimp error: #{e.message}")
            raise e unless e.message.include?("already subscribed to list")
          else
            logger.debug("MailChimp error, ignoring - did you set MAILCHIMP_API_KEY? Message: #{e.message}")
          end
        end
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

      protected

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
          logger.info "Invalid token #{token}"
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

      def ensure_authorized
        begin
          if not request.authorization()
            logger.info "Authorization token not set"
            render_api_response(401, {message: 'Unauthenticated'})
            return
          end
          aa = get_valid_actor_address()
          if not aa or aa.actor_type != 'User'
            render_unauthorized
            return
          end
          @user_id_from_token = aa.actor_id
        rescue Exception => e
          logger.error e
          logger.error e.backtrace.join("\n")
          render_unauthorized
        end
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

      def render_api_response status, contents = {}
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
end
