module Api
  module V0
    class FirmwareController < BaseController
      before_filter :ensure_authorized_or_anonymous

      LINK_EXPIRE_SECS = 60 * 20

      def updates
        # How this currently works
        # - Static mapping of app version to firmware app version
        # - Soft device bootloader etc not really supported

        # TODO - validate parameters - we're currently plugging them into s3 urls which has to be unsafe
        # TODO: app should specify android or ios
        # TODO: need to communicate that app itself needs update

        app_version = params[:appVersion]
        if app_version.nil?
          return render_api_response 400, {code: 'invalid_request_error', message: 'Must specify mobile app version'}
        end

        potential_updates = get_firmware_for_app_version(app_version)
        if potential_updates.nil?
          logger.info "No manifest found for app version #{app_version}"
          return render_empty_response
        end

        updates = []
        potential_updates.each do |u|
          current_version = params[u['versionType']]
          if current_version == u['version']
            logger.info "Correct version for type [#{u['type']}]"
            break
          end
          # TODO - store the versionType / type mapping not in JSON
          u.delete('versionType')
          u['location'] = get_firmware_link(u['type'], u['version'])
          updates << u
        end

        render_api_response 200, {'updates' => updates, 'bootModeType' => 'APPLICATION_BOOT_MODE'}
      end

      private
      def render_empty_response
        render_api_response 200, {:updates => []}
      end

      def get_firmware_for_app_version(version)
        s3_client = AWS::S3::Client.new(region: 'us-east-1')
        bucket_name = Rails.application.config.firmware_bucket
        key_name = "manifests/#{version}/manifest"
        bucket = AWS::S3::Bucket.new(bucket_name, :client => s3_client)
        o = bucket.objects[key_name]
        return nil if !o.exists?
        JSON.parse(o.read)
      end

      def get_firmware_link(type, version)
        s3_client = AWS::S3::Client.new(region: 'us-east-1')
        bucket_name = Rails.application.config.firmware_bucket
        key_name = "joule/#{type}/#{version}/application.bin"
        bucket = AWS::S3::Bucket.new(bucket_name, :client => s3_client)
        o = bucket.objects[key_name]
        o.url_for(:get, {:secure => true, :expires => LINK_EXPIRE_SECS}).to_s
      end
    end
  end
end
