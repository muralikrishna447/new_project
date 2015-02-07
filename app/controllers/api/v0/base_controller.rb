module Api
  module V0
    class BaseController < ActionController::Base

      protected

      def ensure_authorized
        begin
          # Will move this into a environment variable
          key = OpenSSL::PKey::RSA.new File.read('/Users/hnguyen/Desktop/rsa.pem'), 'cooksmarter'
          token = request.authorization().split(' ').last

          # First decode encryption
          decoded = JSON::JWT.decode(token, key)

          # Then decode signature
          verified = JSON::JWT.decode(decoded.to_s, key.to_s)

          # Find a valid user
          user_id = verified['user']['id']
          user = User.find user_id
        rescue Exception => e
          puts e
          render json: {status: '401 Unauthorized'}, status: 401
        end

      end
    end
  end
end