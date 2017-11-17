module Api
  module V0
    class FlagsController < BaseController

      # Used to display temporary flags (alerts) at the top of the website for things like sales or announcement messages
      def index
        begin
          flags = JSON.parse(ENV["CS_FLAGS"])
        rescue Exception => e
          Rails.logger.error "ERROR PARSING FLAGS: #{e}"
        end

        render_api_response 200, { flags: flags }
      end

    end
  end
end
