module Api
  module V0
    module Shopping
      class ProductsController < BaseController
        PREMIUM_DISCOUNT_TAG = 'premium-discount'

        def index
          get_all_products
          render(json: @products)
        end

        # Get product by sku
        def show
          sku = params[:id]
          products = get_all_products
          @product = products.select{|p| p[:sku] == sku}.first
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
        def get_all_products
          @products = Rails.cache.fetch("shopping/products", expires_in: 1.second) do
            results = ShopifyAPI::Product.find(:all)
            results = results.map do |product|
              first_variant = get_first_variant(product)
              {
                id: product.id,
                title: product.title,
                sku: first_variant.sku,
                compare_at_price: get_compare_at_price(product),
                price: get_price(product),
                premium_discount_price: get_product_discount(product),
                variant_id: first_variant.id
              }
            end
            results
          end
        end

        def product_id_by_sku(sku)
          get_all_products
          product = @products.select{|product| product[:sku] == sku}
          return product.first[:id] if product.any?
        end

        def get_product_metafield(product, namespace, key)
          if product.metafields.any?
            metafield = product.metafields.select{|metafield| metafield.namespace == namespace && metafield.key == key}.first
            metafield.value
          end
        end

        # Note: If this method is changed, we will need to update the Shopify Cart script to match.
        def get_product_discount(product)
          discount = nil
          product.tags.split(',').each do |tag|
            if tag.start_with?(PREMIUM_DISCOUNT_TAG)
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
          get_first_variant(product).price.to_i*100
        end

        def get_compare_at_price(product)
          first_variant = get_first_variant(product)
          if first_variant.method_defined? :compare_at_price
            first_variant.compare_at_price.to_i*100
          end
        end

        def get_first_variant(product)
          product.variants.first
        end
      end
    end
  end
end
