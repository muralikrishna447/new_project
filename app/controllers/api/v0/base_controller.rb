module Api
  module V0
    class BaseController < ActionController::Base
      skip_before_filter :verify_authenticity_token
      before_filter :cors_preflight_check
      after_filter :cors_set_access_control_headers

      # For all responses in this controller, return the CORS access control headers.
      def cors_set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
        headers['Access-Control-Max-Age'] = "1728000"
      end

      # If this is a preflight OPTIONS request, then short-circuit the
      # request, return only the necessary headers and return an empty
      # text/plain.

      def cors_preflight_check
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
        headers['Access-Control-Max-Age'] = '1728000'
      end

      def options
        render :text => '', :content_type => 'text/plain'
      end
      
      protected

      def ensure_authorized
        puts "STARTED ensure_authorized"
        begin
          token = request.authorization().split(' ').last

          unless valid_token?(token)
            raise "INVALID TOKEN"
          end
        rescue Exception => e
          puts e
          render json: {status: '401 Unauthorized'}, status: 401
        end
      end

      def create_token(user, exp=nil, restrict_to=nil)
        key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
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
        if verified['exp'] && verified['exp'] <= time_now
          return false
        elsif verified['restrictTo'] && verified['restrictTo'] != restrict_to
          return false
        else
          return verified
        end
      end

    end
  end
end