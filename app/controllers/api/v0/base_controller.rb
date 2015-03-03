module Api
  module V0
    class BaseController < ActionController::Base
      skip_before_filter :verify_authenticity_token
      # before_filter :cors_set_access_control_headers
     
      def cors_set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Origin, Content-Type, Accept, Authorization, Token'
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

      protected

      def ensure_authorized
        begin
          token = request.authorization().split(' ').last

          unless valid_token?(token)
            raise "INVALID TOKEN"
          end
        rescue Exception => e
          puts e
          render json: {status: 401, message: 'Unauthorized.'}, status: 401
        end
      end

      def create_token(user, exp=nil, restrict_to=nil)
        secret = ENV["AUTH_SECRET_KEY"]
        key = OpenSSL::PKey::RSA.new secret, 'cooksmarter'
        issued_at = (Time.now.to_f * 1000).to_i
        claim = {
          iat: issued_at,
          user: {
            id: user.id,
            name: user.name,
            email: user.email
          }
        }
        claim[:exp] = exp if exp
        claim[:restrictTo] = restrict_to if restrict_to

        jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
        jwe = jws.encrypt(key.public_key)
        jwt = jwe.to_s
        # puts "JWS: #{jws}"
        # puts "JWE: #{jwe}"
        # puts "JWT: #{jwt}"
      end

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
          @userid = verified[:user][:id]
          return verified
        end
      end

    end
  end
end