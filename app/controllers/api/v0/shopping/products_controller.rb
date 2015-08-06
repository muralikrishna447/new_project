module Api
  module V0
    module Shopping
      class ProductsController < BaseController
        def show
          product = Rails.cache.fetch("shopping/product/#{params[:id]}", expires_in: 1.minute) do
            product_result = ShopifyAPI::Product.get(params[:id])
            product_result[:quantity] = product_result["variants"].first["inventory_quantity"]
            product_result[:price] = product_result["variants"].first["price"]
            product_result
          end
          render(json: product)
        end
      end
    end
  end
end
