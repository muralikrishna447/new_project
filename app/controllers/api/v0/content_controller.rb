module Api
  module V0
    class ContentController < BaseController
      before_filter :ensure_authorized_or_anonymous

      @@manifest_endpoints = HashWithIndifferentAccess.new

      def manifest
        @@manifest_endpoints = fetch_endpoints

        if @user_id_from_token.nil?
          return redirect_to @@manifest_endpoints['production'], status: 302
        end

        if BetaFeatureService.user_has_feature(current_api_user, 'beta_guides')
          #always use the staging manifest for beta guides users
          Rails.logger.info "ContentController: Beta user #{current_api_user.id} redirecting to staging manifest"
          return redirect_to @@manifest_endpoints['staging'], status: 302
        end

        if @@manifest_endpoints[params[:content_env]]
          redirect_to @@manifest_endpoints[params[:content_env]], status: 302
        else
          Rails.logger.info "ContentController: unknown environment #{params[:content_env]}"
          render_api_response 404
        end
      end

      private
      def fetch_endpoints
        Rails.cache.fetch('manifest_endpoints', expires_in: 60.minutes) do
          YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
        end
      end
    end
  end
end
