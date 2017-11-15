module Api
  module V0
    class PushNotificationTokensController < BaseController
      before_filter :ensure_authorized, only: [:create]
      before_filter :ensure_authorized_or_anonymous, only: [:destroy]

      def create
        return render_api_response 200, {} if find_and_clean_existing(params[:device_token])

        # Orphan SNS endpoints are not a problem so register in SNS first
        begin
          custom_user_data = {
            app_name: params[:app_name],
            actor_address: @actor_address_from_token.address_id,
          }.to_json
          arn = PushNotificationToken.platform_application_arn(params['platform'], params['app_name'])
          if arn.nil?
            return render_api_response 400, {message: "Invalid platform/app [#{params['platform']}] [#{params['app_name']}]"}
          end
          response = create_platform_endpoint(arn, params[:device_token], custom_user_data)
        rescue Aws::SNS::Errors::InvalidParameter => e
          logger.info "Error creating platform endpoint #{e.inspect}"
          return render_api_response 400, {}
        end

        token = create_token(params, response.endpoint_arn)
        if token.errors.size > 0
          logger.warn "Errors: [#{token.errors.inspect}]"
          return render_api_response 400, {message: "Validation failed"}
        end
        return render_api_response 200, {}
      end

      def destroy
        # Deleting tokens is supported without auth because simple posssessing
        # the token is sufficient.  Both the token provided and any token
        # associated with this address are deleted in an effort to not send push
        # notifications to the wrong device.
        if @actor_address_from_token
          token = PushNotificationToken.where(actor_address_id: @actor_address_from_token.id).first
          if token
            logger.info "Found token [#{token.inspect}]"
            delete_token(token)
          end
        end

        token = PushNotificationToken.where(device_token: params[:device_token]).first
        if token
          logger.info "Found token [#{token.inspect}]"
          delete_token(token)
        end
        return render_api_response 200, {}
      end

      private

      def create_token(params, arn)
        token_params = {
          app_name: params[:app_name],
          actor_address_id: @actor_address_from_token.id,
          endpoint_arn: arn,
          device_token: params[:device_token]
        }

        PushNotificationToken.create(token_params)
      end

      def find_and_clean_existing(device_token)
        # Aggressively deletes any possibly conflicting tokens
        existing = PushNotificationToken.where(:device_token => device_token).first
        if existing
          logger.info "Found existing token #{existing}"
          return true if existing.actor_address_id == @actor_address_from_token.id
          delete_token(existing)
        end

        existing = PushNotificationToken.where(:actor_address_id => @actor_address_from_token.id).first
        if existing
          logger.info "Found different token with same address [#{existing.inspect}]"
          delete_token(existing)
        end

        return false
      end

      def delete_token(token)
        logger.info "Deleting token [#{token.inspect}]"
        # Delete token in DB first since orphan endpoints do not cause problems
        token.destroy
        delete_platform_endpoint(token.endpoint_arn)
      end

      # The sns calls are separate because rspec/mock interferes with the aws
      # sdk
      def create_platform_endpoint(platform_application_arn, token, custom_user_data)
        logger.info "Creating platform endpoint [#{platform_application_arn}] [#{token}] [#{custom_user_data}]"
        sns = Aws::SNS::Client.new(region: 'us-east-1')
        sns.create_platform_endpoint(
          platform_application_arn: platform_application_arn,
          token: token,
          custom_user_data: custom_user_data)
      end

      def delete_platform_endpoint(endpoint_arn)
        logger.info "Deleting endpoing with arn [#{endpoint_arn}]"
        sns = Aws::SNS::Client.new(region: 'us-east-1')
        sns.delete_endpoint(endpoint_arn: endpoint_arn)
      end
    end
  end
end
