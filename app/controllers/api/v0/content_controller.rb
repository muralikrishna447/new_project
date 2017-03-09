module Api
  module V0
    class ContentController < BaseController
      before_filter :ensure_authorized_or_anonymous

      def manifest
        manifest_endpoints = YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
        response = {}
        if manifest_endpoints[params[:content_env]]
          redirect_to manifest_endpoints[params[:content_env]], status: 302
        else
          render_api_response 404
        end
      end
    end
  end
end
