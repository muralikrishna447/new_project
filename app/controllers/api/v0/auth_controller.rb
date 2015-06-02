module Api
  module V0
    class AuthController < BaseController
      before_filter :ensure_authorized_service, only: [:validate]

      def authenticate
        begin
          unless params.has_key?(:user)
            logger.info("User not specified #{params.inspect}")
            render json: {status: 400, message: 'Bad Request'}, status: 400
            return
          end

          email = params[:user][:email]
          user = User.find_by_email(email)
          unless user
            logger.info("No account found for email ")
            render_unauthorized
            return
          end

          unless user.valid_password?(params[:user][:password])
            logger.info("Invalid password provided for user #{email}.")
            render_unauthorized
            return
          end

          if params[:token]
            token = AuthToken.from_string(params[:token])
            logger.info "Received token claim #{token.claim.inspect}"
            aa = ActorAddress.find_for_token(token)

            if aa
              if aa.revoked?
                logger.info "User presented revoked token during login"
              elsif aa.actor != user
                logger.info ("Received token for wrong user.")
                render_unauthorized
                return
              else
                aa.double_increment
                render json: {status: 200, message: 'Success.', token: aa.current_token.to_jwt}, status: 200
                return
              end
            else
              logger.info ("No ActorAddress found for token #{token}")
            end
          end

          aa = ActorAddress.create_for_user(user, params[:client_metadata])
          render json: {status: 200, message: 'Success.', token: aa.current_token.to_jwt}, status: 200

        rescue Exception => e
          # TODO - specific issues with the request should be handle as 400
          logger.warn "Authenticate Exception: #{e.class} #{e}"
          logger.error e.backtrace.join("\n")
          render json: {status: 500, message: 'Internal Server Error'}, status: 500
        end
      end

      def authenticate_facebook
        user = User.find_by_email(params[:user][:email])
        aa = ActorAddress.create_for_user user, "facebook"
        if user && user.provider == 'facebook' && user.facebook_user_id == params[:user][:user_id]
          render json: {status: '200 Success', token: aa.current_token.to_jwt}, status: 200
        else
          render_unauthorized
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
          logger.error "Authenticate Exception: #{e.class} #{e}"
          logger.error e.backtrace.join("\n")
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
          render_unauthorized
        end
      end
    end
  end
end
