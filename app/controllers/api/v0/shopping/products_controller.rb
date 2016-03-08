module Api
  module V0
    module Shopping
      class ProductsController < BaseController
        PREMIUM_DISCOUNT_TAG = 'premium-discount'

        def index
          ensure_authorized(false)
          get_all_products(current_api_user)
          render(json: @products)
        end

        # Get product by sku
        def show
          ensure_authorized(false)
          sku = params[:id]
          products = get_all_products(current_api_user)
          @product = products.select{|p| p[:sku] == sku}.first
          if @product
            render(json: @product)
          else
            render(json: {message: 'No product found for sku.'})
          end
        end

        private

        # Caches products with data in a more convient location (price, sku, variant_id) rather than deeply nested
        # This flattens the shopify data to make it easier to work with
        # If we later decide to use variants each having unique skus, this will need to be updated to handle that.
        def get_all_products(current_api_user)
          premium_user = current_api_user && current_api_user.premium?
          # Cache for premium users: shopping/products/premium=true
          # Cache for non-premium users: shopping/products/premium=false
          @products = Rails.cache.fetch("shopping/products/premium=#{premium_user}", expires_in: 1.minute) do
            page = 1
            products = []
            count = ShopifyAPI::Product.count
            if count > 0
              page += count.divmod(250).first
              while page > 0
                products += ShopifyAPI::Product.all(:params => {:page => page, :limit => 250})
                page -= 1
              end
            end
            results = products.map do |product|
              first_variant = get_first_variant(product)
              price = get_price(product, current_api_user)
              discount = get_product_discount(product)
              {
                id: product.id,
                title: product.title,
                sku: first_variant.sku,
                compare_at_price: get_compare_at_price(product),
                price: price,
                premium_discount: discount,
                variant_id: first_variant.id
              }

            end
            results
          end
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

        def get_price(product, current_api_user)
          first_variant = get_first_variant(product)
          first_variant_price = first_variant.price.to_i*100
          discount = get_product_discount(product)
          if current_api_user && current_api_user.premium? && discount
            # There should be a more general way to handle this
            if first_variant.sku == 'cs10001' && current_api_user.used_circulator_discount
              first_variant_price
            else
              first_variant_price - discount
            end
          else
            first_variant_price
          end
        end

        def calculate_discounted_price(price, discount)
          if discount
            price - discount
          end
        end

        def get_compare_at_price(product)
          first_variant = get_first_variant(product)
          first_variant.compare_at_price.to_i*100
        end

        def get_first_variant(product)
          product.variants.first
        end
      end
    end
  end
end
