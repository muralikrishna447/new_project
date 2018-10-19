require 'cache_extensions'

module Api
  module V0
    module Shopping
      class ProductsController < BaseController
        PREMIUM_DISCOUNT_TAG = 'premium-discount'
        before_filter :ensure_authorized_or_anonymous

        def index
          get_all_products
          render(json: @products)
        end

        # Get product by sku
        def show
          sku = params[:id]
          product_sku = get_product_sku(sku)
          products = JSON.parse(get_all_products)
          @product = products.select{|p| p[:product_sku] == product_sku}.first
          if @product
            @variant = @product[:variants].select{|variant| variant[:sku] == params[:id]}[0]
            render(json: @variant)
          else
            render(json: {message: 'No product found for sku.'})
          end
        end

        private
        def get_product_metafield(product, namespace, key)
          if product.metafields.any?
            metafield = product.metafields.select{|metafield| metafield.namespace == namespace && metafield.key == key}.first
            metafield.value
          end
        end

        def get_first_variant(product)
          product.variants.first
        end

        # Product sku is defined as the first segment of a sku
        # Example: a sku of cs10001-blk would have a product sku of cs10001
        def get_product_sku(sku)
          sku.split('-')[0]
        end

        def get_variants(product)
          product.variants.map do |variant|
            variant.attributes

          end
        end
      end
    end
  end
end
