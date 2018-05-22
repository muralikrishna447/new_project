module Api
  module V0
    class ProductsController < BaseController
      def index
        # circulator, premium = Rails.cache.fetch("stripe_products", expires_in: 1.hour){
        #   StripeOrder.stripe_products
        # }
        result = {products: {'cs10001' => {sku: "cs10001", title: "Joule", price: 0, msrp: 0, tax_code: "null", shippable: true},
                             'cs10002' => {sku: "cs10002", title: "Premium", price: 0, msrp: 0, tax_code: "null", shippable: false}}}
        result.merge({location: geolocate_ip()})
        render(json: result)
        # render(json: {}) # When things go 'oh shit' uncomment this line
      end
    end
  end
end
