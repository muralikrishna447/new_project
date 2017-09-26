module Api
  module V0
    module Shopping
      class CountriesController < BaseController
        before_filter :ensure_authorized_or_anonymous

        def intl_enabled
          render(json: CsSpree::Api::Countries.intl_enabled)
        end

        def enabled_countries
          render(json: CsSpree::Api::Countries.enabled_countries)
        end
      end
    end
  end
end
