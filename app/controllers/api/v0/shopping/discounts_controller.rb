require 'cache_extensions'

module Api
  module V0
    module Shopping
      class DiscountsController < BaseController

        def show
          begin
            @discount = CacheExtensions::fetch_with_rescue("shopping/discounts/#{params[:id]}", 1.minute, 1.minute) do
              ShopifyAPI::Discount.find(params[:id])
            end
            @discount.valid = valid?(@discount)
            render_api_response 200, @discount
          rescue
            render_api_response(404, {message: 'Discount not found.'})
          end
        end


        private

        # Adding a :valid attribute because Shopify::Discount can be expired but still enabled
        def valid?(discount)
          expired = (discount.ends_at && DateTime.parse(discount.ends_at) < Date.today) ? true : false
          discount.status == 'enabled' && !expired
        end

      end
    end
  end
end
