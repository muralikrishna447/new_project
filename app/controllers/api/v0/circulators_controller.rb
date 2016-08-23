module Api
  module V0
    class CirculatorsController < BaseController
      before_filter :ensure_authorized, except: [:notify_clients,:coefficients]
      before_filter :ensure_circulator_owner, only: [:update, :destroy]
      before_filter :ensure_circulator_user, only: [:token]
      before_filter :ensure_authorized_service, only: [:notify_clients]

      def index
        @user = User.find @user_id_from_token
        render json: @user.circulators, each_serializer: Api::CirculatorSerializer
      end

      def create
        unless params[:circulator] && params[:circulator][:id]
          # TODO - once we settle on circulator_id format validation should be added
          render_api_response 400, {message: "Must specify circulator.id"}
          return
        end

        User.transaction do
          circulator_id = params[:circulator][:id]
          if Circulator.where(circulator_id: circulator_id).first
            # 400 is not the most helpful error here, we need a way to return
            # richer responses than an HTTP status
            logger.info ("Duplicate circulator id #{circulator_id}")
            render_api_response 409, {message: "Duplicate circulator id."}
            return
          end

          user = User.find @user_id_from_token

          #TODO correctly validate serial number
          circ_params = params[:circulator]
          circulator = Circulator.new
          circulator.notes = circ_params[:notes]
          circulator.name = circ_params[:name]
          circulator.last_accessed_at = Time.now.utc
          circulator.serial_number = circ_params[:serial_number]
          circulator.circulator_id = circulator_id

          secret_key = nil
          if circ_params[:secret_key]
            non_hex = /[^a-fA-F0-9]/
            sk = circ_params[:secret_key]
            if (sk.length != 32 && sk.length != 20) or non_hex.match sk
              render_api_response 400, {message: "Invalid secret key"}
              return
            end
            # We receive a hex encoded string... convert to a binary
            # string before saving to database
            secret_key = [sk].pack('H*')
          end

          circulator.secret_key = secret_key
          logger.info "Creating circulator #{circulator.inspect}"

          circulator.save!
          aa = ActorAddress.create_for_circulator(circulator)
          circulatorUser = CirculatorUser.new user: user, circulator: circulator
          unless params[:owner] == false
            circulatorUser.owner = true
          end
          circulatorUser.save!
          render json: circulator, serializer: Api::CirculatorSerializer
        end
      end

      def update
        if params[:circulator]
          @circulator.name = params[:circulator][:name] if params[:circulator][:name]
          @circulator.notes = params[:circulator][:notes] if params[:circulator][:notes]
        end
        @circulator.last_accessed_at = Time.now.utc
        @circulator.save
        render_api_response 200, {}
      end

      def destroy
        @circulator.destroy
        render_api_response 200
      end

      def token
        # Assume that address_id matches circulator_id
        aa = ActorAddress.where(address_id: @circulator.circulator_id).first
        unless aa
          msg = "ActorAddress not found for circulator id #{circulator_id}"
          raise msg
        end

        render_api_response 200, {token: aa.current_token.to_jwt}
      end

      def notify_clients
        circulator = Circulator.where(circulator_id: params[:id]).first
        if circulator.nil?
          return render_api_response 404, {message: "Circulator not found"}
        end

        if notified?(circulator, params[:idempotency_key])
          return render_api_response 200, { message: 'A notification has already '\
                                                     'been sent for circulator with '\
                                                     "id #{circulator.id} and idempotency "\
                                                     "key #{params[:idempotency_key]}." }
        end

        begin
          message = I18n.t("circulator.push.#{params[:notification_type]}.message", raise: true)
        rescue I18n::MissingTranslationData
          return render_api_response 400, {message: "Unknown notification type #{params[:notification_type]}"}
        end

        notify_owners(circulator, params[:idempotency_key], message)

        render_api_response 200
      end

      def publish_notification(endpoint_arn, message)
        sns = Aws::SNS::Client.new(region: 'us-east-1')
        begin
          # TODO - add APNS once we have a testable endpoint
          title = I18n.t("circulator.app_name", raise: true)
          message = {
            GCM: {data: {message: message, title: title}}.to_json,
            APNS_SANDBOX: {aps: {alert: message}}.to_json,
            APNS: {aps: {alert: message}}.to_json
          }
          logger.info "Publishing #{message.inspect}"
          sns.publish(
            target_arn: endpoint_arn,
            message_structure: 'json',
            message: message.to_json
          )
        rescue Aws::SNS::Errors::EndpointDisabled
          logger.info "Failed to publish to #{endpoint_arn}. Endpoint disabled."
        end
      end

      # Ex: GET /api/v0/circulators/coefficients?identify={ "hardwareVersion": "1.1", "firmwareVersion": "1.1" }
      def coefficients

        # Example data
        coefficientsData = [
          {
            hardwareVersion: '1.1',
            firmwareVersion: '1.1',
            coefficients: {
              tempAdcBias: 1,
              tempAdcScale: 2,
              tempRef: 3,
              tempCoeffA: 4,
              tempCoeffB: 5,
              tempCoeffC: 6
            }
          }
        ]

        identify = JSON.parse params[:identify]
        coefficients = coefficientsData.select{|c| c[:hardwareVersion] == identify['hardwareVersion'] && c[:firmwareVersion] == identify['firmwareVersion']}.first
        if coefficients
          render_api_response 200, coefficients
        else
          render_api_response 404, {message: 'Coefficient does not exist for version provided.'}
        end

      end

      private

      def notified?(circulator, idempotency_key)
        if idempotency_key.blank?
          logger.info "No idempotency_key was specified, will send notification for circulator with id #{circulator.id}"
          return false
        end

        cache_key = notification_cache_key(circulator, idempotency_key)
        if Rails.cache.exist?(cache_key)
          logger.info "Notification cache entry for #{cache_key} found, notification already sent for circulator with id #{circulator.id}"
          return true
        end

        logger.info "No notification cache entry for #{cache_key}, will send notification for circulator with id #{circulator.id}"
        false
      end

      def notify_owners(circulator, idempotency_key, message)
        owners = circulator.circulator_users.select {|cu| cu.owner}
        logger.info "Found circulator owners #{owners.inspect}"

        owners.each do |owner|
          owner.user.actor_addresses.each do |aa|
            logger.info "Found actor address #{aa.inspect}"
            next if aa.revoked?
            token = PushNotificationToken.where(:actor_address_id => aa.id, :app_name => 'joule').first
            next if token.nil?
            logger.info "Publishing to token #{token.inspect}"
            publish_notification(token.endpoint_arn, message)
          end
        end

        set_notified(circulator, idempotency_key)
      end

      def set_notified(circulator, idempotency_key)
        unless idempotency_key.blank?
          Rails.cache.write(
            notification_cache_key(circulator, idempotency_key),
            true,
            expires_in: 72.hours
          )
        end
      end

      def notification_cache_key(circulator, idempotency_key)
        "notifications.#{circulator.id}.#{idempotency_key}"
      end
    end
  end
end
