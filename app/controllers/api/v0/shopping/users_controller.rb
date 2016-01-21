module Api
  module V0
    module Shopping
      class UsersController < BaseController
        # This is multipass with a redirect to a product to add to cart
        # there could come a day where this needs to support a different flow
        # but for the foreseeable future we are going to be
        def multipass
          # NOTE - product_id is actually a VARIANT id
          # return_to = {add_to_cart:true, checkout: true, product_id: params[:product_id]}.to_params
          add_to_cart = "#{params[:product_id]}:#{params[:quantity]}"
          return_to = ("https://#{Rails.configuration.shopify[:store_domain]}" + "/cart/#{add_to_cart}").to_s
          token = Shopify::Multipass.for_user(current_user, return_to)
          # This is for when it is coming from a sign in/up request.
          redirect_to ("https://#{Rails.configuration.shopify[:store_domain]}/account/login/multipass/#{token}").to_s
        end
      end
    end
  end
end
