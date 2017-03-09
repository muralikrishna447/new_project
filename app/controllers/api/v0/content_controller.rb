module Api
  module V0
    class ContentController < BaseController
      before_filter :ensure_authorized_or_anonymous

      def manifest
        manifest_endpoints = {
          'development' => 'http://api.jouleapp.com/manifests/resources.json',
          'staging' => 'https://d1azuiz827qxpe.cloudfront.net/resources/staging/resources.json',
          'beta' => 'https://d1azuiz827qxpe.cloudfront.net/resources/beta/resources.json',
          'production' => 'https://d1azuiz827qxpe.cloudfront.net/resources/latest/resources.json'
        }
        response = {}
        if manifest_endpoints[params[:content_env]]
          response[:manifest_endpoint] = manifest_endpoints[params[:content_env]]
        end
        render_api_response 200, response
      end

    end
  end
end
