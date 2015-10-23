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
        data = {
          "version" => "1.0.0",
          "location" => "https://www.foo.com/firmware.tar.gz"
        }
        render json: data
      end
    end
  end
end
