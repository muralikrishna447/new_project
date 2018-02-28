module Api
  module V0
    class ContentController < BaseController
      before_filter :ensure_authorized_or_anonymous
      DEFAULT_LOCALE = 'en-US'

      # Unfortunately this method needs to be defined before it is called
      def self.refresh_endpoints(additional_endpoints = nil)
        @@manifest_endpoints = YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
        @@manifest_endpoints.merge!(additional_endpoints) if additional_endpoints
        @@manifest_endpoints
      end
      refresh_endpoints
      def manifest
        locale = determine_locale

        if @user_id_from_token.nil?
          return redirect_to @@manifest_endpoints[locale]['production']['default'], status: 302
        end

        if BetaFeatureService.user_has_feature(current_api_user, 'beta_guides')
          #always use the staging manifest for beta guides users
          Rails.logger.info "ContentController: Beta user #{current_api_user.id} redirecting to staging manifest"
          return redirect_to @@manifest_endpoints[locale]['staging']['default'], status: 302
        end

        if @@manifest_endpoints[locale][params[:content_env]]
          redirect_to @@manifest_endpoints[locale][params[:content_env]]['default'], status: 302
        else
          Rails.logger.info "ContentController: unknown environment #{params[:content_env]}"
          render_api_response 404
        end
      end

      private
      def determine_locale
        if !params[:locale]
          logger.info("Locale not specified, using default #{DEFAULT_LOCALE}")
          return DEFAULT_LOCALE
        end

        specified_locale = params[:locale]

        if !supported_locale?(specified_locale)
          logger.info("Locale not supported, using default #{DEFAULT_LOCALE}")
          return DEFAULT_LOCALE
        end

        if !requires_beta_group?(specified_locale)
          logger.info("No beta group required, using specific locale.")
          return specified_locale
        end

        if @user_id_from_token.nil?
          logger.info("User not logged in and specific locale requires beta feature, using default #{DEFAULT_LOCALE}")
          return DEFAULT_LOCALE
        end

        if BetaFeatureService.user_has_feature(current_api_user, beta_group_name(specified_locale))
          logger.info ("User is in beta group #{beta_group_name(specified_locale)}, using specified locale")
          return specified_locale
        end

        logger.info("User not in beta group #{beta_group_name(specified_locale)}, using default #{DEFAULT_LOCALE}")
        return DEFAULT_LOCALE

      end

      def requires_beta_group?(locale)
        return !beta_group_name(locale).nil?
      end

      def beta_group_name(locale)
        @@manifest_endpoints[locale]['beta_group']
      end

      def supported_locale?(locale)
        !@@manifest_endpoints.keys.index(locale).nil?
      end
    end
  end
end
