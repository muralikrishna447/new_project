module Api
  module V0
    class AuthController < ActionController::Base

      def authenticate
        begin
          user = User.find_by_email(params[:user][:email])
          if user && user.valid_password?(params[:user][:password])
            render json: {status: '200 Success', token: create_token(user)}, status: 200
          else
            render json: {status: '401 Unauthorized'}, status: 401
          end
        rescue Exception => e
          puts "Authenticate Exception: #{e.class} #{e}"
          render json: {status: '400 Bad Request'}, status: 400
        end
      end

      private

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