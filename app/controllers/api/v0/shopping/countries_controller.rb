module Api
  module V0
    module Shopping
      class CountriesController < BaseController
        before_filter :ensure_authorized_or_anonymous

        def index
          begin
            @countries = CacheExtensions::fetch_with_rescue("shopping/countries", 10.minutes, 10.minutes) do
              begin
                # r1 = CsSpree::Api::Countries.intl_enabled
                # r2 = CsSpree::Api::Countries.enabled_countries
                r1 = CsSpree.get_api('/api/v1/cs_countries/intl_enabled')
                r2 = CsSpree.get_api('/api/v1/cs_countries/enabled_countries')
                response = {intl_enabled: r1['intl_enabled'], countries: r2['countries']}
                response.to_json
              rescue Exception => e
                raise CacheExtensions::TransientFetchError.new(e)
              end
            end
            render(json: @countries)
          rescue
            render_api_response(404, {message: 'Countries not found.'})
          end
        end

        def set_country
          location = JSON.parse(cookies[:cs_geo])
          location[:country] = params[:country_code]
          cookies['cs_geo'] = {
            :value => location.to_json,
            :domain => :all,
            :expires => Rails.configuration.geoip.cache_expiry.from_now
          }
          render_api_response(200, {message: 'Cookie Set'})
        end

      end
    end
  end
end
