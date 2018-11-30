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
        "APPLICATION_FIRMWARE"  => "appFirmwareVersion",
        "WIFI_FIRMWARE"         => "espFirmwareVersion",
        "BOOTLOADER_FIRMWARE"   => "bootloaderVersion",
        "JOULE_ESP32_FIRMWARE"  => "espFirmwareVersion",
      }

      UPDATE_URGENCIES = ['normal', 'critical', 'mandatory']

      ####################
      # HARDWARE VERSIONS
      ####################
      # JL.p5:  original US production Joule (prototype)
      # J5:     original US production Joule
      # J6:     UL Certified/Canda/Costco Joule
      # J7:     CE Certified/EU Joule
      # JA:     ESP32 Joule (Joule 1.5), 110-120v
      # JB:     ESP32 Joule (Joule 1.5), 220-240v
      ####################
      HW_VERSION_WHITELIST = ['JL.p5', 'J5', 'J6', 'J7', 'JA', 'JB']

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

        if params[:appFirmwareVersion].nil? || params[:espFirmwareVersion].nil? || params[:bootloaderVersion].nil?
          logger.warn("Must specify appFirmwareVersion, espFirmwareVersion, and bootloaderVersion")
          return render_empty_response
        end

        unless dfu_capable?(params)
          logger.info("Not DFU capable")
          return render_empty_response
        end

        hardware_version = params[:hardwareVersion]
        if !HW_VERSION_WHITELIST.include? hardware_version
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
          manifest = get_manifest_for_app_version(app_version)
        rescue ManifestMissingError => e
          logger.info "No manifest found for app version #{app_version}"
          return render_empty_response
        rescue ManifestInvalidError => e
          logger.error "There was a problem with manifest for #{app_version}: #{e}"
          return render_empty_response
        end

        resp = build_response_from_manifest(user, manifest)

        render_api_response 200, resp
      end

      private

      class ManifestMissingError < StandardError
      end

      class ManifestInvalidError < StandardError
      end

      def get_version_number(version_string)
        version_string.match(/s?(\d*)/)[1].to_i # handle staging
      end


      def get_applicable_updates(user, manifest)
        updates = []
        can_downgrade = BetaFeatureService.user_has_feature(user, 'allow_dfu_downgrade')

        manifest["updates"].each do |u|
          param_type = VERSION_MAPPING[u['type']]
          current_version = params[param_type] || ""
          current_version_num = get_version_number(current_version)
          if current_version_num == 0 # to_i converts unknown patterns to 0
            logger.warn "No version information provided for #{u['type']}! Returning no updates"
            return []
          end

          if !u['supported_hw_ver'].include? hardware_version
            logger.info "Update #{u['type']} supports hardware versions #{u['supported_hw_ver']}, but we're looking for #{params[:hardwareVersion]}.  Skipping this update."
            next
          end

          manifest_version_num = get_version_number(u['version'])

          logger.info "#{u['type']}: current [#{current_version}] vs update [#{u['version']}]"

          if current_version_num == manifest_version_num
            logger.info "Correct version for type [#{u['type']}]"
            next
          end

          if (current_version_num > manifest_version_num) && !can_downgrade
            logger.info "Current version #{current_version_num} > #{manifest_version_num} [#{u['type']}]"
            next
          end

          if u['type'] == 'APPLICATION_FIRMWARE'
            u = get_firmware_metadata(u)
          elsif u['type'] == 'BOOTLOADER_FIRMWARE'
            u = get_firmware_metadata(u)
          elsif u['type'] == 'WIFI_FIRMWARE' || u['type'] == 'JOULE_ESP32_FIRMWARE'
            u = get_wifi_firmware_metadata(u)
          end

          # We used to store the versionType in the manifest, but now
          # we have a static mapping defined above
          u.delete('versionType')

          updates << u
        end

        # We always want to apply updates in this order.
        sort_order = {
          "WIFI_FIRMWARE"        => 0,
          "BOOTLOADER_FIRMWARE"  => 1,
          "APPLICATION_FIRMWARE" => 2,
        }
        updates.sort_by! {|u| sort_order[u['type']] }
        return updates
      end

      def build_response_from_manifest(user, manifest)
        updates = get_applicable_updates(user, manifest)
        update_types = updates.map {|u| u['type'] }
        if update_types.include? 'BOOTLOADER_FIRMWARE'
          updates.last['bootModeType'] = 'BOOTLOADER_BOOT_MODE'
        elsif update_types.include? 'APPLICATION_FIRMWARE'
          updates.last['bootModeType'] = 'APPLICATION_BOOT_MODE'
        end


        if BetaFeatureService.user_has_feature(user, 'manifest_urgency')
          manifest_urgency = manifest['urgency'] || 'normal'
        else
          manifest_urgency = 'normal'
        end

        resp = {
          updates: updates,
          releaseNotesUrl: manifest['releaseNotesUrl'],
          releaseNotes: manifest['releaseNotes'],
          urgency: manifest_urgency,
        }

        return resp
      end

      def dfu_capable?(params)
        app_version = Semverse::Version.new(params[:appVersion])

        return app_version >= Semverse::Version.new("2.41.2")
      end

      def get_s3_object_as_json(key)
        s3_client = AWS::S3::Client.new(
          region: 'us-east-1',
          http_read_timeout: 3,
          http_open_timeout: 2,
        )
        bucket_name = Rails.application.config.firmware_bucket
        bucket = AWS::S3::Bucket.new(bucket_name, :client => s3_client)
        o = bucket.objects[key]
        return nil if !o.exists?
        JSON.parse(o.read)
      end

      def get_wifi_firmware_metadata(update)
        type = update['type'] # should always be WIFI_FIRMWARE
        version = update['version']

        # figure out where to look for metadata.json
        case type
        when 'JOULE_ESP32_FIRMWARE'
          metadata_loc = "joule/#{type}/esp32/joule/#{version}/metadata.json"
        else # if not specified, treated as an original NRF Joule
          metadata_loc = "joule/#{type}/#{version}/metadata.json"
        end

        # get the metadata
        metadata = get_s3_object_as_json(metadata_loc)
        u = update.dup

        if type == 'JOULE_ESP32_FIRMWARE'
          filename = "esp32/joule/" + metadata['filename']
        else
          filename = metadata['filename']
        end

        u['transfer'] = [
          {
            "type"        => "tftp",
            # round-robin choose a TFTP host.  DIY load balancing!
            "host"        => Rails.application.config.tftp_hosts.sample,
            "filename"    => filename,
            "sha256"      => metadata['sha256'],
            "totalBytes"  => metadata['totalBytes'],
          },
          {
            "type"        => "http",
            "host"        => Rails.application.config.firmware_download_host,
            "filename"    => filename,
            "sha256"      => metadata['sha256'],
            "totalBytes"  => metadata['totalBytes'],
          },
        ]

        u
      end

      def get_firmware_metadata(update)
        u = update.dup
        link = get_firmware_link(u['type'], u['version'])

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

      def get_manifest_for_app_version(version)
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
          manifest = JSON.parse(o.read)
        rescue JSON::ParserError => e
          raise ManifestInvalidError.new("Bad JSON in manifest")
        end

        unless manifest['releaseNotesUrl']
          raise ManifestInvalidError.new("Manifest is missing releaseNotesUrl")
        end

        unless manifest['releaseNotes'] && manifest['releaseNotes'].length > 0
          raise ManifestInvalidError.new("Manifest is missing releaseNotes array")
        end

        urgency = manifest['urgency']
        if manifest['urgency'] && !UPDATE_URGENCIES.include?(urgency)
          raise ManifestInvalidError.new("Manifest specifies unsupported urgency param: #{urgency}")
        end

        manifest
      end

      def get_firmware_link(type, version)
        file_name = {
          "APPLICATION_FIRMWARE" => "application.bin",
          "BOOTLOADER_FIRMWARE"  => "bootloader.bin",
        }[type]
        s3_client = AWS::S3::Client.new(region: 'us-east-1')
        bucket_name = Rails.application.config.firmware_bucket
        key_name = "joule/#{type}/#{version}/#{file_name}"
        bucket = AWS::S3::Bucket.new(bucket_name, :client => s3_client)
        o = bucket.objects[key_name]
        o.url_for(:get, {secure: true, expires: LINK_EXPIRE_SECS}).to_s
      end
    end
  end
end
