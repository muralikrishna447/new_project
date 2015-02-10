module Api
  module V0
    class BaseController < ActionController::Base

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