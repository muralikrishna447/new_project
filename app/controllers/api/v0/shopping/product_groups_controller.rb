require 'cache_extensions'

module Api
  module V0
    module Shopping
      class ProductGroupsController < BaseController
        before_action :ensure_authorized_or_anonymous

        def index
          # Silently Fails over to US if no iso2 param is provided
          iso2_country_code = (params[:iso2] || 'US').upcase
          @product_groups = CsSpree::Api::ProductGroups.for_country(iso2_country_code)

          if @product_groups.nil?
            render_api_response(500, {message: 'Product Groups not found via API'})
          else
            render(json: @product_groups)
          end
        end
      end
    end
  end
end
