module Api
  module V0
    class ProductsController < BaseController
      def index
        circulator, premium = Rails.cache.fetch("stripe_products", expires_in: 1.hour){
          StripeOrder.stripe_products
        }
        result = {products: {circulator[:sku] => circulator, premium[:sku] => premium}}
        location_result = get_location_result
        Rails.logger.info("Got location result back: #{location_result}")
        result = result.merge(location: location_result)
        render(json: result)
        # render(json: {}) # When things go 'oh shit' uncomment this line
      end


      private
      def sales_tax_states
        ["WA"]
      end

      # Duplicated from the locations controller for short term.
      def get_location_result
        ip_address = get_ip_address
        Rails.logger.info("Geolocation for #{ip_address}")
        result = cache_for_production("location_lookup_#{ip_address}", 1.week) do
          geocode = nil
          catch_and_retry(5) do
            geocode = ((ip_address == '127.0.0.1') ? nil : Geoip2.city(ip_address))
            Rails.logger.info("Geolocation returned for #{geocode}")
          end

          if geocode.present? && geocode.error.blank? && geocode.location.present?
            begin
              ::NewRelic::Agent.record_metric('Custom/Errors/GeocodingForPurchase', 1)
              location = {country: geocode.country.iso_code, latitude: geocode.location.latitude, longitude: geocode.location.longitude, city: geocode.city.try(:names).try(:en), state: geocode.subdivisions.try(:first).try(:iso_code), zip: geocode.try(:postal).try(:code)}
              state = geocode.subdivisions.try(:first).try(:iso_code)
              if state.present? && sales_tax_states.include?(state)
                tax_percent = get_tax_estimate(location)
              else
                tax_percent = nil
              end
            rescue => error
              Rails.logger.error("ProductsController#index - Geocode Error - #{error}")
              location = {country: nil, latitude: nil, longitude: nil, city: nil, state: nil, zip: nil}
              tax_percent = nil
            end
          else
            Rails.logger.info("Failed to geo-locate #{ip_address}")
            ::NewRelic::Agent.record_metric('Custom/Errors/GeocodingForPurchase', 0)
            location = {country: nil, latitude: nil, longitude: nil, city: nil, state: nil, zip: nil}
            tax_percent = nil
          end
          result = location.merge('taxPercent' => tax_percent)
        end
        result
      end

      # Duplicated from locations controller for short term
      def get_ip_address
        (cookies[:cs_location] || request.ip)
      end

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
