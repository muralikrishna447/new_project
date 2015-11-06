module Api
  module V0
    class ProductsController < BaseController
      def index
        location = Geokit::Geocoders::MultiGeocoder.geocode(request.ip)
        if location.success?
          ::NewRelic::Agent.record_metric('Custom/Errors/GeocodingForPurchase', 0)
          tax_percent = get_tax_estimate(location)
        else
          Rails.logger.info("Failed to geo-locate")
          ::NewRelic::Agent.record_metric('Custom/Errors/GeocodingForPurchase', 1)
          tax_percent = nil
        end

        circulator, premium = Rails.cache.fetch("stripe_products", expires_in: 5.minutes){
          StripeOrder.stripe_products
        }
        result = {'taxPercent' => tax_percent, country: location.country_code, state: location.state, products: {circulator[:sku] => circulator, premium[:sku] => premium}}
        render(json: result)
      end

      private
      def get_tax_estimate(location)
        #Null for no geocode and 0 for no tax
        tax_service = AvaTax::TaxService.new
        if location.latitude && location.longitude
          geo_tax_result = tax_service.estimate({latitude: location.latitude, longitude: location.longitude}, 100)
          geo_tax_result["Rate"]
        else
          nil
        end
      end
    end
  end
end
