module Api
  module V0
    class JouleAppRedirectController < BaseController
      def external_redirect_by_key
        key = params[:key]
        unless key
          return render_api_response 400, {message: "No key provided"}
        end

        url = Rails.configuration.joule_app_redirect[params[:key]]
        unless url
          return render_api_response 400, {message: "No redirect for key #{params[:key]}"}
        end

        return render_api_response 200, {redirect: url}
      end
    end
  end
end
