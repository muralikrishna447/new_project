module Api
  module V0
    class BaseController < ActionController::Base

      protected

      def ensure_authorized
        begin
          key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
          token = request.authorization().split(' ').last

          # First decode encryption
          decoded = JSON::JWT.decode(token, key)

          # Then decode signature
          verified = JSON::JWT.decode(decoded.to_s, key.to_s)
        rescue Exception => e
          puts e
          render json: {status: '401 Unauthorized'}, status: 401
        end
      end

      def create_token(user)
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

        jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
        jwe = jws.encrypt(key.public_key)
        jwt = jwe.to_s
        # puts "JWS: #{jws}"
        # puts "JWE: #{jwe}"
        # puts "JWT: #{jwt}"
      end

    end
  end
end