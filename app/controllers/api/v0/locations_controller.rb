module Api
  module V0
    class LocationsController < BaseController
      def index
        location = geolocate_ip()
        location[:country] = 'US' if location[:country].blank?
        render(json: location)
      end
    end
  end
end
