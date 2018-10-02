require 'cache_extensions'

module Api
  module V0
    module Shopping
      class DiscountsController < BaseController

        def show
          raise "DiscountsController deprecated"
          begin
            @discount = CacheExtensions::fetch_with_rescue("shopping/discounts/#{params[:id]}", 1.minute, 1.minute) do
              begin
                ShopifyAPI::Discount.find(params[:id])
              rescue Exception => e
                raise CacheExtensions::TransientFetchError.new(e)
              end
            end
            @discount.valid = valid?(@discount)
            render_api_response 200, @discount.attributes
          rescue
            render_api_response(404, {message: 'Discount not found.'})
          end
        end


        private

        # Adding a :valid attribute because Shopify::Discount can be expired but still enabled
        def valid?(discount)
          # Setting it to PDT -0700 to match Shopify timezone
          end_of_day = Time.now.end_of_day().in_time_zone('Pacific Time (US & Canada)')
          expired = (discount.ends_at && Time.parse(discount.ends_at) < end_of_day) ? true : false
          discount.status == 'enabled' && !expired
        end

      end
    end
  end
end
