module Api
  module V0
    class LocationsController < BaseController
      # For doing geolocation lookup
      def index
        result = Rails.cache.fetch("location_lookup_#{request.ip}", expires_in: 1.week) do
          geocode = nil
          begin
            geocode = ((request.ip == '127.0.0.1') ? nil : Geoip2.city(request.ip))
          rescue => error
            Rails.logger.error("Received error while geocoding #{request.ip}.  #{error}")
          end

          if geocode.present? && geocode.error.blank? && geocode.location.present?
            ::NewRelic::Agent.record_metric('Custom/Errors/GeocodingForPurchase', 1)
            @location = {country: geocode.country.iso_code, latitude: geocode.location.latitude, longitude: geocode.location.longitude, city: geocode.city.names.en, state: geocode.subdivisions.first.iso_code, zip: geocode.postal.code}
            @tax_percent = get_tax_estimate(@location)
          else
            Rails.logger.info("Failed to geo-locate #{request.ip}")
            ::NewRelic::Agent.record_metric('Custom/Errors/GeocodingForPurchase', 0)
            @location = {country: nil, latitude: nil, longitude: nil, city: nil, state: nil, zip: nil}
            @tax_percent = nil
          end
          result = @location.merge('taxPercent' => @tax_percent)
        end
        render(json: result)
      end


      private
      def get_tax_estimate(location)
        #Null for no geocode and 0 for no tax
        tax_service = AvaTax::TaxService.new
        if location[:latitude] && location[:longitude]
          begin
            geo_tax_result = tax_service.estimate({latitude: location[:latitude], longitude: location[:longitude]}, 100)
            geo_tax_result["Rate"]
          rescue => e
            Rails.logger.info("Failed to calculate tax - #{e.response}")
            nil
          end
        else
          nil
        end
      end
    end
  end
end
