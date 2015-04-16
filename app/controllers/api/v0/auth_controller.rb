module Api
  module V0
    class AuthController < BaseController
      before_filter :ensure_authorized_service, only: [:validate]

      def authenticate
        begin
          email = params[:user][:email]
          user = User.find_by_email(email)
          if user
            if user.valid_password?(params[:user][:password])
              render json: {status: 200, message: 'Success.', token: create_token(user)}, status: 200
            else
              logger.info("Invalid password provided for user #{email}.")
              render json: {status: 401, message: 'Unauthorized'}, status: 401
            end
          else
            logger.info("No account found for email ")
            render json: {status: 401, message: 'Unauthorized'}, status: 401
          end
        rescue Exception => e
          # TODO - specific issues with the request should be handle as 400
          logger.warn "Authenticate Exception: #{e.class} #{e}"
          render json: {status: 500, message: 'Internal Server Error'}, status: 500
        end
      end

      def authenticate_facebook
        user = User.find_by_email(params[:user][:email])
        puts params[:user][:email]
        if user && user.provider == 'facebook' && user.facebook_user_id == params[:user][:user_id]
          render json: {status: '200 Success', token: create_token(user)}, status: 200
        else
          render json: {status: 401, message: 'Unauthorized'}, status: 401
        end
      end

      # To be used by the Messaging Service
      # To generate the token, run rake api:generate_service_token[SERVICE_NAME]
      def validate
        begin
          token = params[:token]
          valid_data = valid_token?(token)
          render json: {message: 'Success.', tokenValid: true, data: valid_data}, status: 200
        rescue Exception => e
          logger.warn "Authenticate Exception: #{e.class} #{e}"
          render json: {status: 500, message: 'Internal Server Error'}, status: 500
        end
      end

      private

      def ensure_authorized_service
        allowed_services = ['Messaging']
        request_auth = request.authorization()
        if request_auth
          service_token = request_auth.split(' ').last
          key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
          decoded = JSON::JWT.decode(service_token, key)
          verified = JSON::JWT.decode(decoded.to_s, key.to_s)
          if allowed_services.include? verified[:service]
            return true
          else
            render json: {message: 'Invalid Token.'}, status: 401
          end
        else
          logger.info "No request authorization provided"
          render json: {status: 401, message: 'Unauthorized'}, status: 401
        end
      end

    end
  end
end
