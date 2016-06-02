module Api
  module V0
    class FirmwareController < BaseController
      before_filter :ensure_authorized_or_anonymous

      LINK_EXPIRE_SECS = 60 * 20

      # This maps what's returned by identifyCircul
      VERSION_MAPPING = {
        "appFirmwareVersion" => "APPLICATION_FIRMWARE",
        "espFirmwareVersion" => "WIFI_FIRMWARE",
      }

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
          param_type = VERSION_MAPPING[u['type']]

          current_version = params[param_type]
          if current_version == u['version']
            logger.info "Correct version for type [#{u['type']}]"
            break
          end

          if u['type'] == 'APPLICATION_FIRMWARE'
            u = get_app_firmware_metadata(u)
          elsif u['type'] == 'WIFI_FIRMWARE'
            u = get_wifi_firmware_metadata(u)
          end

          # We used to store the versionType in the manifest, but now
          # we have a static mapping defined above
          u.delete('versionType')

          updates << u
        end

        render_api_response 200, {updates: updates, bootModeType: 'APPLICATION_BOOT_MODE'}
      end

      private

      def get_s3_object_as_json(key)
        s3_client = AWS::S3::Client.new(region: 'us-east-1')
        bucket_name = Rails.application.config.firmware_bucket
        bucket = AWS::S3::Bucket.new(bucket_name, :client => s3_client)
        o = bucket.objects[key]
        return nil if !o.exists?
        JSON.parse(o.read)
      end

      def get_wifi_firmware_metadata(update)
        type = update['type'] # should always be WIFI_FIRMWARE
        version = update['version']
        metadata = get_s3_object_as_json(
          "joule/#{type}/#{version}/metadata.json"
        )

        # round-robin choose a TFTP host.  DIY load balancing!
        tftp_host = Rails.application.config.tftp_hosts.sample

        u = update.dup
        u['transfer'] = {
          "type"        => "tftp",
          "host"        => tftp_host,
          "filename"    => metadata['filename'],
          "sha256"      => metadata['sha256']
        }
        u
      end

      def get_app_firmware_metadata(update)
        u = update.dup
        # TODO: the location key is now deprecated.  Remove this line
        # after breaking change day!
        link = get_firmware_link(u['type'], u['version'])
        u['location'] = link

        # This is the new style
        u['transfer'] = {
          "url" => link,
          "type" => "download",
        }

        u
      end

      def render_empty_response
        render_api_response 200, {:updates => []}
      end

      def get_firmware_for_app_version(version)
        # Sample manifest
        # [
        #  {
        #   "versionType": "appFirmwareVersion",
        #   "type": "APPLICATION_FIRMWARE",
        #   "version": "latest_version"
        #  }
        # ]

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
        o.url_for(:get, {secure: true, expires: LINK_EXPIRE_SECS}).to_s
      end
    end
  end
end
