require_dependency 'beta_feature_service'
require 'semverse'
module Api
  module V0
    class FirmwareController < BaseController
      before_filter :ensure_authorized

      LINK_EXPIRE_SECS = 60 * 60

      # This maps the FileType enum, to the params returned by
      # identifyCirculator
      VERSION_MAPPING = {
        "APPLICATION_FIRMWARE" => "appFirmwareVersion",
        "WIFI_FIRMWARE"        => "espFirmwareVersion"
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

        unless dfu_capable?(params)
          logger.info("Not DFU capable")
          return render_empty_response
        end

        hardware_version = params[:hardwareVersion]
        if hardware_version != 'JL.p5'
          logger.info("Hardware version does not support DFU: #{hardware_version}")
          return render_empty_response
        end

        user = User.find @user_id_from_token

        # Can explicitly blacklist all DFU updates with this 'feature'
        if BetaFeatureService.user_has_feature(user, 'dfu_blacklist')
          logger.info("User #{user.email} is blacklisted from doing DFU")
          return render_empty_response
        end

        # For the time being, each app version needs to be enabled.
        # This allows for rolling updates to groups of users.
        manifest_feature = "dfu_#{app_version}"
        unless BetaFeatureService.user_has_feature(user, manifest_feature)
          logger.info("User #{user.email} is not setup to DFU #{manifest_feature}")
          return render_empty_response
        end

        begin
          manifest = get_firmware_for_app_version(app_version)
        rescue ManifestMissingError => e
          logger.info "No manifest found for app version #{app_version}"
          return render_empty_response
        rescue ManifestInvalidError => e
          logger.error "There was a problem with manifest for #{app_version}: #{e}"
          return render_empty_response
        end

        resp = build_response_from_manifest(manifest)

        render_api_response 200, resp
      end

      private

      class ManifestMissingError < StandardError
      end

      class ManifestInvalidError < StandardError
      end

      def build_response_from_manifest(manifest)
        updates = []
        manifest["updates"].each do |u|
          param_type = VERSION_MAPPING[u['type']]
          current_version = params[param_type]

          logger.info "#{u['type']}: current [#{current_version}] vs update [#{u['version']}]"

          if current_version == u['version']
            logger.info "Correct version for type [#{u['type']}]"
            next
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

        resp = {
          updates: updates,
          releaseNotesUrl: manifest['releaseNotesUrl'],
          releaseNotes: manifest['releaseNotesUrl'],
        }

        return resp
      end

      def dfu_capable?(params)
        app_version = Semverse::Version.new(params[:appVersion])

        return app_version >= Semverse::Version.new("2.41.2")
      end

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
        u = update.dup
        u['transfer'] = [
          {
            "type"        => "tftp",
            # round-robin choose a TFTP host.  DIY load balancing!
            "host"        => Rails.application.config.tftp_hosts.sample,
            "filename"    => metadata['filename'],
            "sha256"      => metadata['sha256'],
            "totalBytes"  => metadata['totalBytes'],
          },
          {
            "type"        => "http",
            "host"        => Rails.application.config.firmware_download_host,
            "filename"    => metadata['filename'],
            "sha256"      => metadata['sha256'],
            "totalBytes"  => metadata['totalBytes'],
          },
        ]

        u
      end

      def get_app_firmware_metadata(update)
        u = update.dup
        link = get_firmware_link(u['type'], u['version'])

        u['bootModeType'] = 'APPLICATION_BOOT_MODE'

        u['transfer'] = [
          {
            "url" => link,
            "type" => "download",
          }
        ]

        u
      end

      def render_empty_response
        render_api_response 200, {:updates => []}
      end

      def get_firmware_for_app_version(version)
        # Sample manifest
        # {
        #  "releaseNotesUrl" : "http://foo.com/release",
        #  "updates" : [{
        #   "versionType": "appFirmwareVersion",
        #   "type": "APPLICATION_FIRMWARE",
        #   "version": "latest_version"
        #  }]
        # }

        s3_client = AWS::S3::Client.new(region: 'us-east-1')
        bucket_name = Rails.application.config.firmware_bucket
        key_name = "manifests/#{version}/manifest"
        bucket = AWS::S3::Bucket.new(bucket_name, :client => s3_client)
        o = bucket.objects[key_name]
        raise ManifestMissingError.new("Could not find manifest for #{version}") unless o.exists?

        begin
          firmware = JSON.parse(o.read)
        rescue JSON::ParserError => e
          raise ManifestInvalidError.new("Bad JSON in manifest")
        end

        unless firmware['releaseNotesUrl']
          raise ManifestInvalidError.new("Manifest is missing releaseNotesUrl")
        end

        unless firmware['releaseNotes'] && firmware['releaseNotes'].length > 0
          raise ManifestInvalidError.new("Manifest is missing releaseNotes array")
        end

        firmware
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
