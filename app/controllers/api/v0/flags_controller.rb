module Api
  module V0
    class FlagsController < BaseController

      # Used to display temporary flags (alerts) at the top of the website for things like sales or announcement messages
      def index
        flags = {
          US: {
            bannerText: ENV["CS_FLAGS_US"] || ""
          }
        }
        render_api_response 200, { flags: flags }
      end

    end
  end
end
