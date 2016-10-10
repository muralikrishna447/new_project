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

      def get_location_result
        tax_percent = nil
        location = geolocate_ip
        if sales_tax_states.include?(location[:state])
          tax_percent = get_tax_estimate(location)
        end
        result = location.merge('taxPercent' => tax_percent)
        result
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
