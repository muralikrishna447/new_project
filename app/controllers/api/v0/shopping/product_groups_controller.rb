require 'cache_extensions'

module Api
  module V0
    module Shopping
      class ProductGroupsController < BaseController
        before_filter :ensure_authorized_or_anonymous

        def index
          # Silently Fails over to US if no iso2 param is provided
          iso2_country_code = (params[:iso2] || 'US').upcase
          @product_groups = CsSpree::Api::ProductGroups.for_country(iso2_country_code)
          render(json: @product_groups)
        end
      end
    end
  end
end
