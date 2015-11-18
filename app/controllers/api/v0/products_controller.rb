module Api
  module V0
    class ProductsController < BaseController
      def index
        circulator, premium = Rails.cache.fetch("stripe_products", expires_in: 5.minutes){
          StripeOrder.stripe_products
        }
        result = {products: {circulator[:sku] => circulator, premium[:sku] => premium}}
        render(json: result)
      end
    end
  end
end
