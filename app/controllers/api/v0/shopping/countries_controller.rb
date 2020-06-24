module Api
  module V0
    module Shopping
      class CountriesController < BaseController
        before_action :ensure_authorized_or_anonymous

        def index
          begin
            @countries = CacheExtensions::fetch_with_rescue("shopping/countries", 10.minute, 10.minute) do
              begin
                r1 = CsSpree::Api::Countries.intl_enabled
                r2 = CsSpree::Api::Countries.enabled_countries
                response = {intl_enabled: r1['intl_enabled'], countries: r2['countries']}
                response.to_json
              rescue Exception => e
                raise CacheExtensions::TransientFetchError.new(e)
              end
            end
            if @countries.nil?
              render_api_response(500, {message: 'Countries not found via API'})
            else
              render(json: @countries)
            end
          rescue
            render_api_response(404, {message: 'Countries not found.'})
          end
        end

      end
    end
  end
end
