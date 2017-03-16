module Admin
  class ShopifyUsersController < ApplicationController

    before_filter :authenticate_active_admin_user!

    def index
      render text: 'ShopifyUsersController'
    end
  end
end