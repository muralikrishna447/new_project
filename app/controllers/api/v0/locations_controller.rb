module Api
  module V0
    class LocationsController < BaseController
      # For doing geolocation lookup
      def index
        ip_address = get_ip_address
        Rails.logger.info("Geolocation for #{ip_address}")
        result = cache_for_production("location_lookup_#{ip_address}", 1.week) do
          geocode = nil
          catch_and_retry(5) do
            geocode = ((ip_address == '127.0.0.1') ? nil : Geoip2.city(ip_address))
            Rails.logger.info("Geolocation returned for #{geocode}")
          end

          if geocode.present? && geocode.error.blank? && geocode.location.present?
            ::NewRelic::Agent.record_metric('Custom/Errors/GeocodingForPurchase', 1)
            begin
              @location = {country: geocode.country.iso_code, latitude: geocode.location.latitude, longitude: geocode.location.longitude, city: geocode.city.try(:names).try(:en), state: geocode.subdivisions.try(:first).try(:iso_code), zip: geocode.try(:postal).try(:code)}
              @tax_percent = get_tax_estimate(@location)
            rescue => error
              Rails.logger.error("LocationsController#index - Geocode Error - #{error}")
              @location = {country: nil, latitude: nil, longitude: nil, city: nil, state: nil, zip: nil}
              @tax_percent = nil
            end
          else
            Rails.logger.info("Failed to geo-locate #{ip_address}")
            ::NewRelic::Agent.record_metric('Custom/Errors/GeocodingForPurchase', 0)
            @location = {country: nil, latitude: nil, longitude: nil, city: nil, state: nil, zip: nil}
            @tax_percent = nil
          end
          result = @location.merge('taxPercent' => @tax_percent)
        end
        render(json: result)
      end


      private
      def get_ip_address
        unless Rails.env.production?
          (cookies[:cs_location] || request.ip)
        else
          request.ip
        end
      end

      # def cache_for_production(ip_address)
      #   result = nil
      #   if Rails.env.production?
      #     result = Rails.cache.fetch("location_lookup_#{ip_address}", expires_in: 1.week) do
      #       yield
      #     end
      #   else
      #     result = yield
      #   end
      #   return result
      # end

      def get_tax_estimate(location)
        #Null for no geocode and 0 for no tax
        tax_service = AvaTax::TaxService.new
        if location[:latitude] && location[:longitude]
          begin
            geo_tax_result = tax_service.estimate({latitude: location[:latitude], longitude: location[:longitude]}, 100)
            geo_tax_result["Rate"]
          rescue => e
            Rails.logger.error("Failed to calculate tax - #{e.response}")
            nil
          end
        else
          nil
        end
      end
    end
  end
end
