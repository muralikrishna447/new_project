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
      class UsersController < BaseController
        # This is multipass with a redirect to a product to add to cart
        # there could come a day where this needs to support a different flow
        # but for the foreseeable future we are going to be
        def multipass
          # return_to = {add_to_cart:true, checkout: true, product_id: params[:product_id]}.to_params
          add_to_cart = "#{params[:product_id]}:#{params[:quantity]}"
          token = ShopifyMultipass.new.generate_token(user_data(add_to_cart))
          # This is for when it is coming from a sign in/up request.
          if params[:autoredirect]
            redirect_to (ShopifyAPI::Base.site + "/account/login/multipass/#{token}").to_s
          else
            render(json: {redirect_to: (ShopifyAPI::Base.site + "/account/login/multipass/#{token}").to_s})
          end
        end

        private
        def user_data(add_to_cart)
          {
            email: current_user.email,
            first_name: current_user.name.split(' ')[0],
            last_name: (current_user.name.split(' ').size > 1 ? current_user.name.split(' ')[1] : nil),
            return_to: ShopifyAPI::Base.site + "/cart/#{add_to_cart}"
          }
        end
      end
    end
  end
end
