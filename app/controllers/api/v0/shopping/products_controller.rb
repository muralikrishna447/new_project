module Api
  module V0
    module Shopping
      class ProductsController < BaseController

        def index
          get_cached_products
          render(json: @products)
        end

        # Get product by sku
        def show
          sku = params[:id]
          product_id = product_id_by_sku(sku)
          if product_id
            @product = Rails.cache.fetch("shopping/products/#{product_id}", expires_in: 1.second) do
              result = ShopifyAPI::Product.get(product_id)
              result
            end
            render(json: @product)
          else
            render(json: {message: 'No product found for sku.'})
          end

        end

        private
        def get_cached_products
          @products = Rails.cache.fetch("shopping/products", expires_in: 1.second) do
            results = ShopifyAPI::Product.find(:all)
            results = results.map do |product|
              {
                id: product.id,
                title: product.title,
                sku: product.variants.first.sku
              }
            end
            results
          end
        end

        def product_id_by_sku(sku)
          get_cached_products
          product = @products.select{|product| product[:sku] == sku}
          return product.first[:id] if product.any?
        end
      end
    end
  end
end
