module Api
  module V0
    class LocationsController < BaseController
      def index
        if Rails.env.development?
          location = {:country=>'US', :latitude=>nil, :longitude=>nil, :city=>nil, :state=>nil, :zip=>nil}
        else
          location = geolocate_ip()
        end
        render(json: location)
      end
    end
  end
end
