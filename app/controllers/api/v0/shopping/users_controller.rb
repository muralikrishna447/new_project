module Api
  module V0
    module Shopping
      class UsersController < BaseController
        # This is multipass with a redirect to a product to add to cart
        # there could come a day where this needs to support a different flow
        # but for the foreseeable future we are going to be
        def multipass
          # return_to = {add_to_cart:true, checkout: true, product_id: params[:product_id]}.to_params
          add_to_cart = "#{params[:product_id]}:#{params[:quantity]}"
          token = ShopifyMultipass.new.generate_token(user_data(add_to_cart))
          # This is for when it is coming from a sign in/up request.
          redirect_to ("https://delve.myshopify.com/account/login/multipass/#{token}").to_s
        end

        private
        def user_data(add_to_cart)
          {
            email: current_user.email,
            first_name: current_user.name.split(' ')[0],
            last_name: (current_user.name.split(' ').size > 1 ? current_user.name.split(' ')[1] : nil),
            return_to: (ShopifyAPI::Base.site + "/cart/#{add_to_cart}").to_s
          }
        end
      end
    end
  end
end
