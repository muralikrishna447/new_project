module Api
  module V0
    class ProductsController < BaseController
      def index
        # circulator, premium = Rails.cache.fetch("stripe_products", expires_in: 1.hour){
        #   StripeOrder.stripe_products
        # }
        result = {products: {'cs10001' => '', 'cs10002' => ''}}
        result.merge({location: geolocate_ip()})
        render(json: result)
        # render(json: {}) # When things go 'oh shit' uncomment this line
      end
    end
  end
end
