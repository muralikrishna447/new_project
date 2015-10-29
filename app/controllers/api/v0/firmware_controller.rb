module Api
  module V0
    class FirmwareController < BaseController
      before_filter :ensure_authorized_or_anonymous

      def latest_version
        if @user_id_from_token
          @user = User.find @user_id_from_token
        else
          @user = nil
        end
        version = 'v1.0.0'

        link = get_firmware_link('v1.0.0')
        data = {
          "version" => version,
          "location" => link
        }
        render json: data
      end

      private

      def get_firmware_link(version)
        s3_client = AWS::S3::Client.new(region: 'us-east-1')
        bucket_name = Rails.application.config.firmware_bucket
        key_name = "joule/#{version}/application.bin"
        bucket = AWS::S3::Bucket.new(bucket_name, :client => s3_client)
        o = bucket.objects[key_name]
        expire_secs = 60 * 5
        o.url_for(:get, {:secure => true, :expires => expire_secs}).to_s
      end
    end
  end
end
