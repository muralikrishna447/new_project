module Api
  module V0
    class AuthController < BaseController
      before_filter :ensure_authorized_service, only: [:validate]
      before_filter :ensure_authorized, only: [:logout, :external_redirect]
      instrument_action :authenticate

      def authenticate
        begin
          unless params.has_key?(:user) && params[:user].has_key?(:email)
            logger.info("User not specified #{params.inspect}")
            render json: {status: 400, message: 'Bad Request'}, status: 400
            return
          end

          email = params[:user][:email].downcase
          logger.info "Looking up user for [#{email}]"
          user = User.find_by_email(email)

          unless user
            logger.info("No account found for email ")
            render_unauthorized
            return
          end

          if user.deleted_at.present?
            logger.info("User has been deleted")
            render_unauthorized
            return
          end

          unless user.valid_password?(params[:user][:password])
            logger.info("Invalid password provided for user #{email}.")
            render_unauthorized
            return
          end

          if params[:token]
            begin
              token = AuthToken.from_string(params[:token])
            rescue JSON::JWS::VerificationFailed
              logger.info ("Token verification failed")
              render_unauthorized
              return
            end
            logger.info "Received token claim #{token.claim.inspect}"
            aa = ActorAddress.find_for_token(token)

            if aa
              if aa.revoked?
                logger.info "User presented revoked token during login"
                render_unauthorized
                return
              elsif aa.actor != user
                logger.info ("Received token for wrong user.")
                return render_unauthorized
              else
                aa.double_increment
                return render json: {status: 200, message: 'Success.', token: aa.current_token.to_jwt}, status: 200
              end
            else
              logger.info ("No ActorAddress found for token #{token}")
              return render_unauthorized
            end
          end

          aa = ActorAddress.create_for_user(user, client_metadata: params[:client_metadata])
          render json: {status: 200, message: 'Success.', token: aa.current_token.to_jwt}, status: 200

        rescue Exception => e
          # TODO - specific issues with the request should be handle as 400
          logger.warn "Authenticate Exception: #{e.class} #{e}"
          logger.error e.backtrace.join("\n")
          render json: {status: 500, message: 'Internal Server Error'}, status: 500
        end
      end

      def authenticate_facebook
        access_token = params[:user][:access_token]
        facebook_user_id = params[:user][:user_id]

        # Get an oauth token with our credentials
        # This will be used later to validate the access_token we recieve from the client
        oauth = Koala::Facebook::OAuth.new(facebook_app_id, facebook_secret)
        app_access_token = oauth.get_app_access_token

        fb = Koala::Facebook::API.new(app_access_token)

        # Use debug to check the validity of the token
        fb.debug_token(access_token) do |response|
          logger.info "Facebook debug_token response: #{response}"
          response_data = response['data']
          if response_data && response_data['is_valid'] && response_data['app_id'] == facebook_app_id && response_data['user_id'] == facebook_user_id
            fb_user_api = Koala::Facebook::API.new(access_token)
            fb_user = fb_user_api.get_object('me')
            fb_user_id = fb_user['id']

            # Search for existing user
            cs_user = User.where(email: fb_user['email']).first
            if cs_user && cs_user.provider != 'facebook'
              cs_user.facebook_connect({user_id: fb_user_id})
              # render_api_response 401, {message: 'Please provide ChefSteps password.', user: {id: cs_user.id, email: cs_user.email}}
              logger.info "Existing ChefSteps user attempted to log in with Facebook. email: #{cs_user.email}"
            end

            cs_fb_user = User.where(facebook_user_id: fb_user_id).first

            new_user = false
            if cs_fb_user
              # If the user exists in ChefSteps
              # Store the Facebook UserID
              cs_fb_user.facebook_connect({user_id: fb_user_id})
              logger.info "Existing ChefSteps user connected with facebook: #{cs_fb_user.email}"
            else
              # If the user does not exist in ChefSteps
              # Use the information from the Facebook API
              new_user = true
              user_options = {
                name: fb_user['name'],
                email: fb_user['email'],
                user_id: fb_user_id
              }
              cs_fb_user = User.facebook_connect(user_options)
              cs_fb_user.save!
              subscribe_and_track cs_fb_user, false, 'facebook'
              logger.info "New ChefSteps user connected with facebook: #{cs_fb_user.email}"
            end

            aa = ActorAddress.find_for_user_and_unique_key(cs_fb_user, 'facebook')
            unless aa
              aa = ActorAddress.create_for_user cs_fb_user, client_metadata: "facebook", unique_key: "facebook"
            end
            logger.info "ActorAddress created for facebook user: #{aa.inspect}"
            # newUser param is returned for client side FTUE flows
            render_api_response 200, {token: aa.current_token.to_jwt, newUser: new_user}
          else
            render_unauthorized
          end
        end

      end

      # Modified from https://github.com/zendesk/zendesk_jwt_sso_examples/blob/master/ruby_on_rails_jwt.rb
      # General doc: https://support.zendesk.com/hc/en-us/articles/203663816-Setting-up-single-sign-on-with-JWT-JSON-Web-Token-
      def zendesk_sso_url(return_to)
        iat = Time.now.to_i
        jti = "#{iat}/#{SecureRandom.hex(18)}"

        payload = JWT.encode({
          iat: iat, # Seconds since epoch, determine when this token is stale
          jti: jti, # Unique token id, helps prevent replay attacks
          name: current_api_user.name,
          email: current_api_user.email,
          user_fields: {
            premium: current_api_user.premium?
          }
        }, ENV['ZENDESK_SHARED_SECRET'])

        url = "https://#{ENV['ZENDESK_DOMAIN']}/access/jwt?jwt=#{payload}"
        url += "&return_to=#{URI.escape(return_to)}" if return_to.present?
        url
      end

      # Used for SSO with third-party services
      def external_redirect
        path = params[:path]

        logger.info "[redirect] Determing external redirect for path [#{path}]"

        begin
          path_uri = URI.parse(params[:path])
        rescue URI::InvalidURIError
          return render_api_response 400, {message: "Path [#{params[:path]}] is not valid URI."}
        end

        if path_uri.host == Rails.configuration.shopify[:store_domain]
          path_params =  Rack::Utils.parse_nested_query(path_uri.query)
          if path_params['checkout_url']
            return_to = path_params['checkout_url']
          else
            return_to = "https://#{Rails.configuration.shopify[:store_domain]}/account"
          end

          token =  Shopify::Multipass.for_user(current_api_user, return_to)
          redirect_uri = "https://#{Rails.configuration.shopify[:store_domain]}/account/login/multipass/#{token}"
          render_api_response 200, {redirect: redirect_uri}
        elsif path_uri.host == 'pitangui.amazon.com'
          # TODO - user restricted token if this is used for more than testing
          token = @actor_address_from_token.current_token.to_jwt
          redirect_params = {state: params[:state],
            token_type: 'Bearer',
            access_token: token}
          redirect_uri = path_uri.to_s+"##{redirect_params.to_query}"
          render_api_response 200, {redirect: redirect_uri}

        elsif path_uri.host == "#{ENV['ZENDESK_DOMAIN']}" || path_uri.host == "#{ENV['ZENDESK_MAPPED_DOMAIN']}"
          render_api_response 200, {redirect: zendesk_sso_url(params[:path])}

        else
          return render_api_response 404, {message: "No redirect configured for path [#{path}]."}
        end
      end

      # To be used by the Messaging Service
      # To generate the token, run rake api:generate_service_token[SERVICE_NAME]
      def validate
        begin
          begin
            token = AuthToken.from_string(params[:token])
          rescue JSON::JWS::VerificationFailed
            logger.info ("Token verification failed for [#{params[:token]}]")
            render_api_response 400, {code: 'invalid_token', message: 'Token verification failed.'}
            return
          rescue JSON::JWT::InvalidFormat
            logger.info ("Invalid token format [#{params[:token]}]")
            render_api_response 400, {code: 'invalid_token', message: 'Token verification failed.'}
            return
          end

          aa = ActorAddress.find_for_token(token)
          unless aa
            render_api_response 401, {message: 'No ActorAddress for token'}
            return
          end

          unless aa.valid_token? token
            render_api_response 401, {message: 'Invalid token'}
            return
          end

          addressable_addresses = aa.addressable_addresses.map{|a| a.address_id}

          # TODO: We are storing minimal info in the claim itself, and
          # decorating with other data on validate.
          resp = {
            message: 'Success.',
            tokenValid: true,
            addressableAddresses: addressable_addresses,
            actorType: aa.actor_type, # this one can probably be in claim
            data: token.claim,
          }

          render json: resp, status: 200
        rescue Exception => e
          logger.error "Authenticate Exception: #{e.class} #{e}"
          logger.error e.backtrace.join("\n")
          render json: {status: 500, message: 'Internal Server Error'}, status: 500
        end
      end

      def logout
        # For now, don't invalidate token since we're re-using the actor address
        # across multiple sessions
        user = User.find (@user_id_from_token)
        if user
          # Warden logout will clear rememberable and set logged-out session cookie
          warden.logout
          render_api_response 200
        else
          logger.info "No user found for id [#{@user_id_from_token}]"
          render_unauthorized
        end
      end
    end
  end
end
