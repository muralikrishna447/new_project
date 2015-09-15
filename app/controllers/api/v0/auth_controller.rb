module Api
  module V0
    class AuthController < BaseController
      before_filter :ensure_authorized_service, only: [:validate]
      before_filter :ensure_authorized, only: [:logout]
      instrument_action :authenticate

      def authenticate
        begin
          unless params.has_key?(:user)
            logger.info("User not specified #{params.inspect}")
            render json: {status: 400, message: 'Bad Request'}, status: 400
            return
          end

          email = params[:user][:email]
          logger.info "Looking up user for [#{email}]"
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

        puts '*'*30
        puts '*'*30

        access_token = params[:user][:access_token]
        user_id = params[:user][:user_id]
        puts "access_token: #{access_token}"
        puts "user_id: #{user_id}"

        oauth = Koala::Facebook::OAuth.new(facebook_app_id, facebook_secret)
        puts "oauth: #{oauth.inspect}"
        app_access_token = oauth.get_app_access_token
        puts "app_access_token: #{app_access_token}"

        fb = Koala::Facebook::API.new(app_access_token)
        fb.debug_token(access_token) do |response|
          puts "Response: #{response}"
          response_data = response['data']
          if response_data && response_data['is_valid'] && response_data['user_id'] == user_id
            fb_user_api = Koala::Facebook::API.new(access_token)
            fb_user = fb_user_api.get_object('me')
            fb_user_id = fb_user['id']
            puts "me: #{fb_user.inspect}"
            cs_user = User.where(email: fb_user['email']).first

            if cs_user
              puts "CS USER EXISTS!"
              cs_user.facebook_connect({user_id: fb_user_id})
            else
              puts "CS USER DOES NOT EXIST!"
              cs_user = User.new({
                name: fb_user['name'],
                email: fb_user['email']
              })
              cs_user = User.facebook_connect({user_id: fb_user_id})
            end

            aa = ActorAddress.create_for_user cs_user, client_metadata: "facebook"
            render json: {status: '200 Success', token: aa.current_token.to_jwt}, status: 200

          else
            render_unauthorized
          end
        end

        # fb = Koala::Facebook::API.new(params[:user][:authentication_token])
        # puts fb.debug_token(params[:user][:user_id])
        puts '*'*30
        puts '*'*30
        # puts fb.get_object('chefsteps')
        # exit
        #
        # oauth = Koala::Facebook::OAuth.new("249352241894051", "57601926064dbde72d57fedd0af8914f") #copied from staging
        # #app_access_token = oauth.get_app_access_token
        # app_access_token = "249352241894051|57601926064dbde72d57fedd0af8914f" # concatenated access token
        # puts "Access token: #{app_access_token}"
        # oauth_access_token = 'CAADiyNfNUqMBAFmuk7iVEKK0a2eKj764HoXTILI0aGAFtZBMZCBbOjokZA54ZA4vjhw6uAM9lGauyYZCqzwcPW2sxxgi26X3JeW4Ge0dIVhUgkW5C5ZBzTOc5QKoFvCzQ1uE0c1f3cpCOZBkLtZCP6e7R3mMlWfME8YQNfSyKO7hXkaYYwVCoK96MhraLryBiD7s5xdyvzVtbKVIQqlcDc6l'
        # fb = Koala::Facebook::API.new(app_access_token)
        # puts fb.inspect
        # #puts fb.get_object("me").inspect
        # puts fb.debug_token(oauth_access_token)
        # puts fb.debug_token(app_access_token)
        #
        # fb = Koala::Facebook::API.new(oauth_access_token)
        # puts fb.get_object("me").inspect

        # Verify Facebook Token

        # Find ChefSteps User

        # If user exists log them in

        # If user does not exist, create an account


        # user = User.find_by_email(params[:email])
        # aa = ActorAddress.create_for_user user, client_metadata: "facebook"
        # if user && user.provider == 'facebook' && user.facebook_user_id == params[:facebook_user_id]
        #   render json: {status: '200 Success', token: aa.current_token.to_jwt}, status: 200
        # else
        #   render_unauthorized
        # end
      end

      # To be used by the Messaging Service
      # To generate the token, run rake api:generate_service_token[SERVICE_NAME]
      def validate
        begin
          token = AuthToken.from_string(params[:token])

          aa = ActorAddress.find_for_token(token)
          unless aa
            render json: {status: 401, meessage: 'No ActorAddress for token'}
            return
          end

          unless aa.valid_token? token
            render json: {status: 401, meessage: 'Invalid token'}
            return
          end

          render json: {message: 'Success.', tokenValid: true, data: token.claim}, status: 200
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

      private
      def ensure_authorized_service
        allowed_services = ['Messaging']
        request_auth = request.authorization()
        if request_auth
          token = AuthToken.from_string(request_auth.split(' ').last)
          if allowed_services.include? token.claim['service']
            return true
          else
            logger.info "Unauthorized claim: #{token.claim.inspect}"
            render_unauthorized
          end
        else
          logger.info "No request authorization provided"
          render_unauthorized
        end
      end
    end
  end
end
