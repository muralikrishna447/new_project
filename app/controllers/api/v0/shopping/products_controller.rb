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
          products = get_all_products
          @product = products.select{|p| p[:product_sku] == product_sku}.first
          if @product
            @variant = @product[:variants].select{|variant| variant[:sku] == params[:id]}[0]
            render(json: @variant)
          else
            render(json: {message: 'No product found for sku.'})
          end
        end

        private

        # Caches products with data in a more convient location (price, sku, variant_id) rather than deeply nested
        # This flattens the shopify data to make it easier to work with
        # If we later decide to use variants each having unique skus, this will need to be updated to handle that.
        def get_all_products
          @products = CacheExtensions::fetch_with_rescue("shopping/products", 1.minute, 1.minute) do
            page = 1
            products = []
            begin
              count = ShopifyAPI::Product.count
            rescue Exception => e
              raise CacheExtensions::TransientFetchError.new(e)
            end

            if count > 0
              page += count.divmod(250).first
              while page > 0
                begin
                  page_of_products = ShopifyAPI::Product.all(:params => {:page => page, :limit => 250})
                rescue Exception => e
                  raise CacheExtensions::TransientFetchError.new(e)
                end
                products += page_of_products
                page -= 1
              end
            end

            products = products.select do |product|
              first_variant = get_first_variant(product)
              is_valid = first_variant && first_variant.sku
              unless is_valid
                logger.warn "Filtering out product with no variant/sku: #{product.id} #{product.title}"
              end
              is_valid
            end


            results = products.map do |product|
              first_variant = get_first_variant(product)

              product_images = product.images.map do |image|
                {
                  product_id: image.product_id,
                  src: image.src,
                  variant_ids: image.variant_ids
                }
              end

              {
                id: product.id,
                title: product.title,
                sku: get_product_sku(first_variant.sku),
                variants: get_variants(product),
                images: product_images
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
