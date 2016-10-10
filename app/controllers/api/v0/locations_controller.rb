module Api
  module V0
    class LocationsController < BaseController
      def index
        location = geolocate_ip()
        result = location.merge('taxPercent' => nil)
        render(json: result)
      end
    end
  end
end
