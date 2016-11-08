module Api
  module V0
    class LocationsController < BaseController
      def index
        location = geolocate_ip()
        if sales_tax_states.include?(location[:state])
          tax_percent = get_tax_estimate(location)
        end
        result = location.merge('taxPercent' => tax_percent)
        render(json: result)
      end

      protected
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

      def sales_tax_states
        ["WA"]
      end

    end
  end
end
