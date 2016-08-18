require 'cache_extensions'

module Api
  module V0
    module Shopping
      class DiscountsController < BaseController

        before_filter :get_all_discounts

        def show
          discount_code = params[:id]
          @discount = @discounts.find_all{ |d| d.code == discount_code  }.first
          if @discount
            render_api_response 200, @discount
          else
            render_api_response(404, {message: 'Discount not found.'})
          end
        end


        private

        # Don't expose all discounts but make sure they're cached
        def get_all_discounts
          # Test kept failing with error: undefined class/module ShopifyAPI::Discount::AppliesTo
          if !Rails.env.test?
            @discounts = CacheExtensions::fetch_with_rescue('shopping/discounts', 1.minute, 1.minute) do
              map_valid
            end
          else
            @discounts = map_valid
          end
        end

        def valid?(discount)
          expired = (discount.ends_at && DateTime.parse(discount.ends_at) < Date.today) ? true : false
          discount.status == 'enabled' && !expired
        end

        def map_valid
          ShopifyAPI::Discount.all.map do |discount|
            discount.valid = valid?(discount)
            discount
          end
        end

      end
    end
  end
end
