module Api
  module V0
    class LocationsController < BaseController
      def index
        location = geolocate_ip()
        render(json: location)
      end
    end
  end
end
