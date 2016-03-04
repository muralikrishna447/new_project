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
          products = get_cached_products
          @product = Rails.cache.fetch("shopping/products/#{sku}", expires_in: 1.second) do
            products.select{|p| p[:sku] == sku}.first
          end
          if @product
            render(json: @product)
          else
            render(json: {message: 'No product found for sku.'})
          end
        end

        private

        # Caches products with data in a more convient location (msrp, price, sku, variant_id) rather than deeply nested
        # This flattens the shopify data to make it easier to work with
        # If we later decide to use variants each having unique skus, this will need to be updated to handle that.
        def get_cached_products
          @products = Rails.cache.fetch("shopping/products", expires_in: 1.second) do
            results = ShopifyAPI::Product.find(:all)
            results = results.map do |product|
              {
                id: product.id,
                title: product.title,
                sku: product.variants.first.sku,
                msrp: get_product_metafield(product, 'price', 'msrp'),
                price: get_price(product),
                premium_discount_price: get_product_discount(product),
                variant_id: product.variants.first.id
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

        def get_product_metafield(product, namespace, key)
          if product.metafields.any?
            metafield = product.metafields.select{|metafield| metafield.namespace == namespace && metafield.key == key}.first
            metafield.value
          end
        end

        def get_product_discount(product)
          discount = nil
          product.tags.split(',').each do |tag|
            if tag.start_with?('premium-discount')
              discount = tag.split(":")[1].to_i
            end
          end
          discount
        end

        def get_variant_id_for_sku(variants, sku)
          variant = variants.select{|v| v.sku == sku }
          return variants.first.id
        end

        def get_price(product)
          product.variants.first.price.to_i*100
        end
      end
    end
  end
end
