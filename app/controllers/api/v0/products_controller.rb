module Api
  module V0
    class ProductsController < BaseController
      def index
        tax_percent = get_tax_estimate
        products =  Rails.cache.fetch("stripe_products", expires_in: 5.minutes){
          Stripe::Product.all(active: true)
        }
        circulator = premium = nil
        products.each do |product|
          sku = product.skus.first
          if product.id == 'cs-premium'
            premium = {sku: sku.id, title: product.name, price: (sku.price.to_f/100.0), msrp: (sku.metadata[:msrp].to_f/100.0), shippable: product.shippable}
          elsif product.id == 'cs-joule'
            circulator = {sku: sku.id, title: product.name, price: (sku.price.to_f/100.0), msrp: (sku.metadata[:msrp].to_f/100.0), 'premiumPrice' => (sku.metadata[:premium_price].to_f/100.0), shippable: product.shippable}
          end
        end

        result = {'taxPercent' => tax_percent, products: {circulator[:sku] => circulator, premium[:sku] => premium}}
        render(json: result)
      end

      def show
        results = Rails.cache.fetch("stripe_results/#{params[:id]}", expires_in: 5.minutes){
          sku = Stripe::SKU.retrieve(params[:id])
          product = Stripe::Product.retrieve(sku.product)
          result_values = {name: product.name, caption: product.description, description: product.caption, shippable: product.shippable, active: sku.active, price: (sku.price/100.0), msrp: (sku.metadata[:msrp]/100.0), discount: (sku.metadata[:preorder]/100.0)}
        }
        render(json: results)
      end

      private
      def get_tax_estimate
        #Null for no geocode and 0 for no tax
        tax_service = AvaTax::TaxService.new
        location = Geokit::Geocoders::MultiGeocoder.geocode(request.ip)
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
