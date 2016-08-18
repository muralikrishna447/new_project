module Api
  module V0
    module Shopping
      class DiscountsController < BaseController

        before_filter :get_all_discounts

        def show
          discount_code = params[:id]
          @discount = @discounts.find_all{ |d| d.code == discount_code  }.first
          if @discount
            render(json: @discount)
          else
            render(json: {message: 'No discount found.'})
          end
        end

        # Don't expose all discounts but make sure they're cached
        private
        def get_all_discounts
          @discounts = CacheExtensions::fetch_with_rescue('shopping/discounts', 1.minute, 1.minute) do
            ShopifyAPI::Discount.all
          end
        end
        
      end
    end
  end
end
