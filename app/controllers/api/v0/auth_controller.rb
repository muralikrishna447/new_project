module Api
  module V0
    class AuthController < BaseController
      before_filter(BaseController.make_service_or_admin_filter(
        [ExternalServiceTokenChecker::MESSAGING_SERVICE]), only: [:validate])
      before_filter :ensure_authorized, only: [:logout, :external_redirect, :authorize_ge_redirect, :refresh_ge]

      def authenticate
        begin
          Librato.increment("api.authenticate_requests")
          unless params.has_key?(:user) && params[:user].has_key?(:email)
            logger.info("User not specified #{params.inspect}")
            render_api_response 400, {message: 'Bad Request'}
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
                return render_api_response 200, {message: 'Success.', token: aa.current_token.to_jwt}
              end
            else
              logger.info ("No ActorAddress found for token #{token}")
              return render_unauthorized
            end
          end

          aa = ActorAddress.create_for_user(user, client_metadata: params[:client_metadata])
          render_api_response 200, { message: 'Success.', token: aa.current_token.to_jwt}

        rescue Exception => e
          # TODO - specific issues with the request should be handle as 400
          logger.warn "Authenticate Exception: #{e.class} #{e}"
          logger.error e.backtrace.join("\n")
          render_api_response 500, {message: 'Internal Server Error'}
        end
      end

      def authorize_ge_redirect
        logger.info "Going to generate authorization url"
        payload = JWT.encode({
          unique: Time.now, # Could be used to help prevent replay attacks
          id: current_api_user.id
        }, ENV['OAUTH_SECRET'])

        redirect_url = GE::Client.auth_code.authorize_url(:redirect_uri => GE::RedirectURL, access_type: "offline", state: payload)
        return render_api_response 200, {redirect: redirect_url}
      end

      def refresh_ge
        logger.info "Refreshing token for user #{current_api_user.id}"
        ge_token = current_api_user.oauth_tokens.ge.first
        unless ge_token
          logger.error "User #{current_api_user.id} doesn't have a GE Token"
          return render_api_response 401, {message: 'No GE token to refresh'}
        end
        # token = Oauth2::Token.new(GE::Client, ge_token.token, {refresh_token: ge_token.refresh_token, expires_at: ge_token.expires_at})

        params = {:client_id      => GE::Client.id,
                    :client_secret  => GE::Client.secret,
                    :grant_type     => 'refresh_token',
                    :refresh_token  => ge_token.refresh_token}
        token = GE::Client.get_token(params)
        ge_token.token = token.token
        ge_token.token_expires_at = Time.at(token.expires_at)
        ge_token.refresh_token = token.refresh_token
        if ge_token.save
          logger.info "Saved oauth token (#{ge_token.id})."
          return render_api_response 200, {message: 'Success.', token: ge_token.token, expires_at: ge_token.token_expires_at, refresh_token: ge_token.refresh_token}
        else
          logger.error "Error saving oauth record.  #{ge_token.errors.to_sentence}"
          return render_api_response 500, {message: "Error saving attributes"}
        end
      end

      def authenticate_ge
        logger.info "Received response from the ge server"
        Librato.increment("api.authenticate_ge_requests")
        code = params[:code]
        payload = JWT.decode(params[:state], ENV['OAUTH_SECRET'])
        user = User.find(payload["id"]) rescue nil
        begin
          token = GE::Client.auth_code.get_token(code, :redirect_uri => GE::RedirectURL)
        rescue OAuth2::Error
          token = nil
        end

        if user.blank?
          logger.error "User from id #{payload} did not match a CS User."
          return render_api_response 401, {message: 'Invalid user'}
        end
        if token.blank?
          logger.error "Code could not be exchanged for an auth token"
          return render_api_response 401, {message: 'Invalid token'}
        end
        logger.info "Setting user (#{user.id}) attributes"
        oauth_record = user.oauth_tokens.where(service: "ge").first || OauthToken.new(user_id: user.id, service: "ge")
        oauth_record.token = token.token
        oauth_record.token_expires_at = Time.at(token.expires_at)
        oauth_record.refresh_token = token.refresh_token
        if oauth_record.save
          logger.info "Saved oauth token (#{oauth_record.id})."
          return render_api_response 200, {message: 'Success.', token: oauth_record.token, expires_at: oauth_record.token_expires_at, refresh_token: oauth_record.refresh_token}
        else
          logger.error "Error saving oauth record.  #{oauth_record.errors.to_sentence}"
          return render_api_response 500, {message: "Error saving attributes"}
        end
      end

      def authenticate_facebook
        Librato.increment("api.authenticate_facebook_requests")
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
            fb_user = fb_user_api.get_object('me', {fields: 'email,name,id'}) # Now required to explicity get email

            if !fb_user['email']
              logger.info "Failed to authenticate Facebook, email missing for access_token: #{access_token}"
              render_api_response 400, {message: "Failed to authenticate Facebook.  Email field is missing."} and return
            end

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
        Librato.increment("api.authenticate_zendesk_sso_url_requests")
        iat = Time.now.to_i
        jti = "#{iat}/#{SecureRandom.hex(18)}"

        payload = JWT.encode({
          iat: iat, # Seconds since epoch, determine when this token is stale
          jti: jti, # Unique token id, helps prevent replay attacks
          name: current_api_user.name,
          email: current_api_user.email,
          external_id: current_api_user.id.to_s,
          user_fields: {
            premium: current_api_user.premium?
          }
        }, ENV['ZENDESK_SHARED_SECRET'])

        url = "https://#{ENV['ZENDESK_DOMAIN']}/access/jwt?jwt=#{payload}"
        url += "&return_to=#{URI.escape(return_to)}" if return_to.present?
        url
      end

      def chefsteps_sso_url(path)
        short_lived_token = AuthToken.provide_short_lived(@current_token).to_jwt
        url = "https://www.#{Rails.application.config.shared_config[:chefsteps_endpoint]}/sso?token=#{short_lived_token}"
        url += "&path=#{path}" if path.present?
        url
      end

      def spree_sso_url(path)
        short_lived_token = AuthToken.provide_short_lived(@current_token).to_jwt
        url = "#{Rails.application.config.shared_config[:spree_endpoint]}/sso?token=#{short_lived_token}"
        url += "&path=#{path}" if path.present?
        url
      end

      def localhost_spree_sso_url(path_uri)
        short_lived_token = AuthToken.provide_short_lived(@current_token).to_jwt
        port = path_uri.port.present? ? ":#{path_uri.port}" : ''
        url = "#{path_uri.scheme}://#{path_uri.host}#{port}/sso?token=#{short_lived_token}"
        url += "&path=#{path_uri.to_s}"
        url
      end

      # Used for SSO with third-party services
      # DOES NOT ACTUALLY REDIRECT
      # Returns a json object with a redirect url
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
            return_to = path_uri.to_s
          end

          token =  Shopify::Multipass.for_user(current_api_user, return_to)
          redirect_uri = "https://#{Rails.configuration.shopify[:store_domain]}/account/login/multipass/#{token}"
          render_api_response 200, {redirect: redirect_uri}

        elsif path_uri.host == 'pitangui.amazon.com'
          aa = ActorAddress.create_for_user(current_api_user, {client_metadata: 'amazon'})
          token = aa.current_token.to_jwt
          redirect_params = {state: params[:state],
            token_type: 'Bearer',
            access_token: token}
          redirect_uri = path_uri.to_s+"##{redirect_params.to_query}"
          render_api_response 200, {redirect: redirect_uri}

        elsif path_uri.host == 'oauth-redirect.googleusercontent.com'
          aa = ActorAddress.create_for_user(current_api_user, {client_metadata: 'google-action'})
          token = aa.current_token.to_jwt
          redirect_params = {state: params[:state],
            token_type: 'Bearer',
            access_token: token}
          redirect_uri = path_uri.to_s+"##{redirect_params.to_query}"
          render_api_response 200, {redirect: redirect_uri}

        elsif path_uri.host == Rails.application.config.shared_config[:facebook][:messenger_endpoint]
          aa = ActorAddress.create_for_user(current_api_user, {client_metadata: 'facebook-messenger'})
          token = aa.current_token.to_jwt
          redirect_params = {
            authorization_code: token
          }
          redirect_uri = path_uri
          redirect_uri.query = [redirect_uri.query, redirect_params.to_query].compact.join('&')
          render_api_response 200, {redirect: redirect_uri.to_s}

        elsif path_uri.host == "#{ENV['ZENDESK_DOMAIN']}" || path_uri.host == "#{ENV['ZENDESK_MAPPED_DOMAIN']}"
          render_api_response 200, {redirect: zendesk_sso_url(params[:path])}

        elsif path_uri.host == "www.#{Rails.application.config.shared_config[:chefsteps_endpoint]}"
          render_api_response 200, {redirect: chefsteps_sso_url(params[:path])}

        elsif path_uri.host == Rails.application.config.shared_config[:spree_domain]
          render_api_response 200, {redirect: spree_sso_url(params[:path])}
        elsif (Rails.env.staging? || Rails.env.staging2?) && path_uri.host == 'localhost'
          render_api_response 200, {redirect: localhost_spree_sso_url(path_uri)}
        else
          return render_api_response 404, {message: "No redirect configured for path [#{path}]."}
        end
      end

      def external_redirect_by_key
        key = params[:key]
        unless key
          return render_api_response 400, {message: "No key provided"}
        end

        #if the key parameter is a shopify url, simply use that url for the redirect
        url = shopify_url?(key) ? key : Rails.configuration.redirect_by_key[params[:key]]
        unless url
          logger.error("unrecognized key provided to redirect_by_key")
          return render_api_response 200, {redirect: Rails.configuration.redirect_by_key['fallback']}
        end

        if not request.authorization()
          return render_api_response 200, {redirect: url}
        end

        params[:path] = url
        ensure_authorized()
        return external_redirect()
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
            capabilities: get_capabilities_for_actor_address(aa),
          }

          render_api_response 200, resp
        rescue Exception => e
          logger.error "Authenticate Exception: #{e.class} #{e}"
          logger.error e.backtrace.join("\n")
          render_api_response 500, {message: 'Internal Server Error'}
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

      def upgrade_token
        ensure_authorized(true)
        token_string = request.headers['HTTP_AUTHORIZATION'].split(' ')[1]
        token = AuthToken.from_string(token_string)
        logger.info "Trying to upgrade token: #{token.claim.inspect}"
        jti = token.claim["jti"]
        cache_key = "jwt-#{jti}"
        was_used = Rails.cache.fetch(cache_key)
        if was_used
          return render_api_response 403, {message: 'Token has been used'}
        end

        upgraded_token = AuthToken.upgrade_token(token_string)
        if upgraded_token
          Rails.cache.write cache_key, 1, expires_in: 1.days
          return render_api_response 200, {message: 'Success.', token: upgraded_token.to_jwt}
        else
          return render_unauthorized
        end

      end

      private

      def get_capabilities_for_actor_address(aa)
        # Only circ capabilities for now
        unless aa.actor_type == 'Circulator'
          return []
        end
        logger.info "Searching for capabilities for ActorAddress #{aa.id}"
        capability_list = [
          'predictive',
          'usage_data',
        ]
        cache_key = "aa-capabilities-#{aa.id}"
        return Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          circulator = Circulator.includes(:circulator_users) \
                         .find(aa.actor_id)
          owners = circulator.circulator_users.select {|cu| cu.owner}
          if owners.length > 1
            logger.warn "Unhandled: circulator #{circulator.id} has multiple owners."
            return []
          end
          owner = owners.first.user
          logger.info "Using capabilities for user #{owner.id} for ActorAddress #{aa.id}"
          user_groups_cache = BetaFeatureService.get_groups_for_user(owner)
          capability_list.select {|c|
            BetaFeatureService.user_has_feature(owner, c, user_groups_cache)
          }
        end
      end

    end
  end
end
