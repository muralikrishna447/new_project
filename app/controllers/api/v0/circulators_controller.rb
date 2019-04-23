require_dependency 'beta_feature_service'
require_dependency 'external_service_token_checker'
module Api
  module V0
    class CirculatorsController < BaseController
      @@dynamo_client = Aws::DynamoDB::Client.new(region: 'us-east-1')

      before_filter :ensure_authorized, except: [:notify_clients, :admin_notify_clients, :coefficients]
      before_filter :ensure_circulator_owner, only: [:update, :destroy]
      before_filter :ensure_circulator_user, only: [:token]
      before_filter(BaseController.make_service_or_admin_filter(
        [ExternalServiceTokenChecker::MESSAGING_SERVICE]), only: [:notify_clients])
      before_filter(BaseController.make_service_or_admin_filter(
        [ExternalServiceTokenChecker::ADMIN_PUSH_SERVICE]), only: [:admin_notify_clients])

      def index
        @user = User.find @user_id_from_token
        render json: @user.circulators, each_serializer: Api::CirculatorSerializer
      end

      def create
        Librato.increment("api.circulator_create_requests")
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

          begin
            aa = ActorAddress.create_for_circulator(circulator)
          rescue ArgumentError
            return render_api_response 400, {message: "Invalid parameters"}
          end
          circulatorUser = CirculatorUser.new user: user, circulator: circulator
          unless params[:owner] == false
            circulatorUser.owner = true
          end
          circulatorUser.save!
          render json: circulator, serializer: Api::CirculatorSerializer
        end
      end

      def update
        Librato.increment("api.circulator_update_requests")
        if params[:circulator]
          @circulator.name = params[:circulator][:name] if params[:circulator][:name]
          @circulator.notes = params[:circulator][:notes] if params[:circulator][:notes]
        end
        @circulator.last_accessed_at = Time.now.utc
        @circulator.save
        render_api_response 200, {}
      end

      def destroy
        Librato.increment("api.circulator_destroy_requests")
        @circulator.destroy
        render_api_response 200
      end

      def token
      Librato.increment("api.circulator_token_requests")
        # Assume that address_id matches circulator_id
        aa = ActorAddress.where(address_id: @circulator.circulator_id).first
        unless aa
          msg = "ActorAddress not found for circulator id #{circulator_id}"
          raise msg
        end

        render_api_response 200, {token: aa.current_token.to_jwt}
      end

      def notify_clients
        Librato.increment("api.circulator_notify_clients_requests")
        circulator = Circulator.where(circulator_id: params[:id]).first
        if circulator.nil?
          return render_api_response 404, {message: "Circulator not found"}
        end

        if check_and_set_notified(circulator, params[:idempotency_key])
          return render_api_response 200, { message: 'A notification has already '\
                                                     'been sent for circulator with '\
                                                     "id #{circulator.id} and idempotency "\
                                                     "key #{params[:idempotency_key]}." }
        end

        begin
          push_notification = get_push_notification(circulator.circulator_id)
        rescue MissingNotificationError
          return render_api_response 400, {message: "Unknown notification type #{params[:notification_type]}"}
        end

        logger.info "Attempting to send notification for #{circulator.circulator_id}" \
                    " of type #{params[:notification_type]}"
        notify_owners circulator, params[:idempotency_key], push_notification

        render_api_response 200
      end

      def publish_notification(user, circulator, token, push_notification, is_admin_message)
        Librato.increment("api.publish_notification_requests")

        gcm_data = render_for_gcm(push_notification)
        apns_data = render_for_apns(push_notification)

        if is_admin_message
          #copy additional params into gcm_data and apns_data
          ["headerIcon",
               "headerColor",
               "titleString",
               "bodyString",
               "okText",
               "cancelText",
               "redirectKey"].each do |key|
            gcm_data[:data][key] = params[key] if params.key?(key)
            apns_data[:aps][key] = params[key] if params.key?(key)
          end
        end

        message = {
          GCM: gcm_data.to_json,
          APNS_SANDBOX: apns_data.to_json,
          APNS: apns_data.to_json,
        }

        logger.info "Publishing #{message.inspect}"
        endpoint_arn = token.endpoint_arn
        begin
          resp = publish_json_message(endpoint_arn, message.to_json)
          save_push_notification(
            resp[:message_id], user, circulator, token, push_notification
          )
        rescue Aws::SNS::Errors::EndpointDisabled
          # NOTE: Clean up any disabled endpoints, since they're
          # likely not useful anymore.  There is a chance that Apple
          # tokens can get 'disabled' even though they are still
          # valid.  But the app should re-register the token the next
          # time it boots up.
          #
          # See: https://forums.aws.amazon.com/thread.jspa?threadID=152300

          logger.info "Failed to publish to #{endpoint_arn} because endpoint disabled. Deleting token and endpoint."
          token.destroy
          delete_endpoint(endpoint_arn)
        end
      end

      def admin_notify_clients
        Librato.increment("api.circulator_admin_notify_clients_requests")

        @circulator = Circulator.where(circulator_id: params[:id]).first
        if @circulator.nil?
          return render_api_response 404, {message: "Circulator not found"}
        end

        unless params[:idempotency_key]
          return render_api_response 400, {message: "You must pass the idempotency_key parameter."}
        end

        if check_and_set_notified(@circulator, params[:idempotency_key], true)
          return render_api_response 200, { message: 'A notification has already '\
                                                     'been sent for circulator with '\
                                                     "id #{@circulator.id} and idempotency "\
                                                     "key #{params[:idempotency_key]}." }
        end

        begin
          push_notification = get_admin_push_notification()
        rescue MissingNotificationError
          return render_api_response 400, {message: "Unknown notification type #{params[:notification_type]}"}
        rescue InvalidParamsError => e
          return render_api_response 400, {message: e.message}
        end

        logger.info "Attempting to send notification for #{@circulator.circulator_id}" \
                    " of type #{params[:notification_type]}"

        notify_owners @circulator, params[:idempotency_key], push_notification, true
        render_api_response 200, { notification: push_notification.message }
      end


      # NOTE: Do not add logic to this method!! Want to keep this as
      # thin as possible for testing purposes (because we have to mock
      # it out due to weird interactions between Rspec and AWS)
      def publish_json_message(endpoint_arn, json_str)
        sns = Aws::SNS::Client.new(region: 'us-east-1')
        r = sns.publish(
          target_arn: endpoint_arn,
          message_structure: 'json',
          message: json_str
        )
        return r.data
      end

      def save_push_notification(message_id, user, circulator, token, push_notification)
        item = {
          'message_id' => message_id,
          'user_id' => user.id,
          'notification_type' => push_notification.notification_type,
          'circulator_address' => circulator.circulator_id,
          'status' => 'posted',
          'endpoint_arn' => token.endpoint_arn,
          'created_at' => Time.now.iso8601(),
          'ttl' => (Time.now + 90.days).to_i,
        }
        item.update(push_notification.params)
        save_push_notification_item_to_dynamo(item)
      end

      def save_push_notification_item_to_dynamo(item)
        @@dynamo_client.put_item({
          table_name: Rails.configuration.dynamodb.push_notifications_table,
          item: item,
        })
      end

      def delete_endpoint(endpoint_arn)
        sns = Aws::SNS::Client.new(region: 'us-east-1')
        sns.delete_endpoint(endpoint_arn: endpoint_arn)
      end

      # Ex: POST /api/v0/circulators/coefficients
      # POST params :identify
      def coefficients
        Librato.increment("api.coefficients_requests")

        # Example data
        coefficientsData = [
          {
            hardwareVersion: 'JL.p4',
            appFirmwareVersion: '48',
            coefficients: {
              tempAdcBias: -65536,
              tempAdcScale: 7.629452739355006e-06, # (1.0f / (65535 - -65536))
              tempRef: 2.49e4, #2.49e4f
              tempCoeffA: 0.0012978594740199803, # cs_config_mgmt.c - Line 62
              tempCoeffB: 0.00020601808214437865, # cs_config_mgmt.c - Line 63
              tempCoeffC: 2.0092461335894591e-07 # cs_config_mgmt.c - Line 64
            }
          },
          {
            hardwareVersion: 'JL.p5',
            appFirmwareVersion: '47',
            coefficients: {
              tempAdcBias: -65536,
              tempAdcScale: 7.629452739355006e-06, # (1.0f / (65535 - -65536))
              tempRef: 2.49e4, #2.49e4f
              tempCoeffA: 0.0011796801475685386, # cs_config_mgmt.c - Line 67
              tempCoeffB: 0.00022517119372778328, # cs_config_mgmt.c - Line 68
              tempCoeffC: 1.269031122320061e-07 # cs_config_mgmt.c - Line 69
            }
          }
        ]

        identify = params[:identify]

        if identify && identify['hardwareVersion'] && identify['appFirmwareVersion']
          coefficients = coefficientsData.select{|c| c[:hardwareVersion] == identify['hardwareVersion'] && c[:appFirmwareVersion] == identify['appFirmwareVersion']}.first
          if coefficients
            render_api_response 200, coefficients
          else
            render_api_response 200, {hardwareVersion: identify['hardwareVersion'], appFirmwareVersion: identify['appFirmwareVersion'], coefficients: {}}
          end
        else
          render_api_response 404, {message: 'Not found. Please provide {identify} with hardwareVersion and appFirmwareVersion params.'}
        end

      end

      private

      class MissingNotificationError < StandardError
      end

      class InvalidParamsError < StandardError
      end

      class PushNotification
        attr_reader :notification_type, :message, :params, :is_background, :notification_id

        def initialize(notification_type, message: nil, params: nil, is_background: false)
          @notification_type = notification_type
          @message = message
          @params = params || {}
          @is_background = is_background
          @notification_id = PushNotification.get_notification_id()
        end

        ANDROID_MAX_INT = 2147483647

        def self.get_notification_id
          # This is used for grouping notifications, and also for
          # letting iOS know we're finished processing background
          # notifications. For now just use a random number (must be
          # less than the max value of an integer, on Android).  See:
          # https://github.com/phonegap/phonegap-plugin-push/blob/master/docs/PAYLOAD.md#notification-id
          return rand(ANDROID_MAX_INT)
        end
      end

      def render_for_apns(push_notification)
        data = push_notification.params.merge({
          notification_type: push_notification.notification_type,
        })

        aps = {}

        if push_notification.message
          aps[:alert] = push_notification.message
          if push_notification.notification_type == 'cook_finished'
            aps[:sound] =  'www/sounds/timer.caf'
          else
            aps[:sound] =  'default'
          end
        end

        if push_notification.is_background
          aps['content-available'.to_sym] = 1
          data[:notId] = push_notification.notification_id
        end

        return data.merge({
          aps: aps,
        })
      end

      def render_for_gcm(push_notification)
        data = push_notification.params.merge({
          notification_type: push_notification.notification_type,
        })

        if push_notification.message
          data[:message] = push_notification.message
          data[:title] = I18n.t("circulator.app_name", raise: true)
        end

        if push_notification.is_background
          # GCM requires a string value of '1', APNS requires an integer value of 1
          data['content-available'.to_sym] = '1'
          data[:notId] = push_notification.notification_id
        end

        return {
          data: data
        }
      end

      def get_push_notification(circulator_address)
        notification_type = params[:notification_type]

        # Other metadata that we want to pass on to the app
        keys = ['feed_id', 'finish_timestamp', 'joule_name', 'guide_id', 'timer_id', 'cook_time', 'cook_start_timestamp', 'cook_finished_notification']
        additional_params = (params[:notification_params] || {}).select{
          |k,v| keys.include? k
        }
        additional_params[:circulator_address] = circulator_address

        if ['timer_updated', 'still_preheating'].include?(notification_type)
          return PushNotification.new(
            notification_type, params: additional_params, is_background: true
          )
        end

        message = get_notification_message(notification_type, params[:notification_params])
        return PushNotification.new(
          notification_type, message: message, params: additional_params
        )
      end

      def get_notification_message(notification_type, notification_params)
        message = nil

        template_params = (notification_params || {}).inject({}){|memo,(k,v)|
          unless v.nil?
            memo[k.to_sym] = v; memo
          end
          memo
        }

        begin
          template = I18n.t("circulator.push.#{notification_type}.template", raise: true)
          message = template % template_params
        rescue I18n::MissingTranslationData
          logger.info "No template found for #{notification_type}, falling back to default"
        rescue KeyError
          logger.warn "Bad params for #{notification_type}, falling back to default"
        end

        unless message
          begin
            message = I18n.t("circulator.push.#{notification_type}.message", raise: true)
          rescue I18n::MissingTranslationData
            raise MissingNotificationError.new("Missing notification for #{notification_type}")
          end
        end
        return message
      end

      def get_admin_push_notification
        notification_type = params[:notification_type]

        if notification_type != 'dynamic_alert'
          raise MissingNotificationError.new("Unknown notification type for #{notification_type}")
        end

        ['message', 'okText'].each do |param|
          unless params.key?(param)
            raise InvalidParamsError.new("#{param} parameter must be specified")
          end
        end

        unless shopify_url?(params[:redirectKey])
          if params[:redirectKey].present?
            raise InvalidParamsError.new("unrecognized redirect key: #{params[:redirectKey]}") unless Rails.configuration.redirect_by_key.key?(params[:redirectKey])
          end
        end

        notification_params = (params[:notification_params] || {}).inject({}){|memo,(k,v)|
          unless v.nil?
            memo[k.to_sym] = v; memo
          end
          memo
        }

        return PushNotification.new(
          notification_type, message: params[:message]
        )
      end

      def check_and_set_notified(circulator, idempotency_key, enforce_idempotency_key=false)
        unless enforce_idempotency_key
          if idempotency_key.blank?
            logger.info "No idempotency_key was specified, will send notification for circulator with id #{circulator.id}"
            return false
          end
        end

        # Set notified right away, to avoid duplicate notifications.
        # We still have a small race condition, which could be
        # eliminated by using the check-and-set method, although the
        # semantics of that method are a bit weird
        # http://www.rubydoc.info/github/mperham/dalli/Dalli/Client#cas-instance_method
        cache_key = notification_cache_key(circulator, idempotency_key)
        if Rails.cache.exist?(cache_key)
          logger.info "Notification cache entry for #{cache_key} found, notification already sent for circulator with id #{circulator.id}"
          return true
        end
        set_notified(circulator, params[:idempotency_key])

        logger.info "No notification cache entry for #{cache_key}, will send notification for circulator with id #{circulator.id}"
        false
      end

      def notify_owners(circulator, idempotency_key, push_notification, is_admin_message=false)
        owners = circulator.circulator_users.select {|cu| cu.owner}

        owners.each do |owner|
          logger.info "Found circulator owner #{owner.user.id}"
          owner.user.actor_addresses.each do |aa|
            logger.info "Found actor address #{aa.inspect}"
            next if aa.revoked?
            token = PushNotificationToken.where(:actor_address_id => aa.id, :app_name => ['joule', 'joule-beta']).first
            next if token.nil?
            logger.info "Publishing notification to user #{owner.user.id} for #{circulator.circulator_id}" \
                        " of type #{push_notification.notification_type} token_id=#{token.id} ARN=#{token.endpoint_arn}"
            publish_notification(owner.user, circulator, token, push_notification, is_admin_message)
          end
        end
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
