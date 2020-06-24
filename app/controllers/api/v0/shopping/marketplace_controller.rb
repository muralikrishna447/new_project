module Api
  module V0
    module Shopping
      class MarketplaceController < BaseController
        before_action :ensure_authorized_or_anonymous

        @@marketplace_guides = HashWithIndifferentAccess.new

        def guide_button
          guide_id = params[:guide_id]
          fetch_marketplace_guides

          if @@marketplace_guides[guide_id]
            Rails.logger.info "Matching marketplace guide"
            render_button = false
            if @@marketplace_guides[guide_id][:feature_name].blank?
              render_button = true
            else
              if @user_id_from_token.present?
                render_button = BetaFeatureService.user_has_feature(current_api_user, @@marketplace_guides[guide_id][:feature_name])
              end
            end

            if render_button
              button_text = @@marketplace_guides[guide_id][:button_text]
              button_text_line_2 = @@marketplace_guides[guide_id][:button_text_line_2]

              button = {button: {line_1: button_text }}
              button[:button][:line_2] = button_text_line_2 if button_text_line_2
              return render_api_response 200, button
            end
          end
          return render_no_button
        end

        def guide_button_redirect
          guide_id = params[:guide_id]
          fetch_marketplace_guides
          if @@marketplace_guides[guide_id]
            Rails.logger.info "Matching with marketplace guide."
            return_to = @@marketplace_guides[guide_id][:url]
          elsif guide_id == STEAK_GUIDE_ID
            Rails.logger.info "Matching with hard-coded steak guide."
            return_to = "https://#{Rails.configuration.shopify[:store_domain]}/products/double-r-ranch-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf"
          else
            Rails.logger.info "No match, returning store root"
            return_to = "https://#{Rails.configuration.shopify[:store_domain]}/"
          end

          if @user_id_from_token
            # Cut and pasted from external redirect, for now
            token =  Shopify::Multipass.for_user(current_api_user, return_to)
            redirect_uri = "https://#{Rails.configuration.shopify[:store_domain]}/account/login/multipass/#{token}"
            return render_api_response 200, {redirect: redirect_uri}
          else
            return render_api_response 200, {redirect: return_to}
          end
        end

        private
        def render_no_button
          render_api_response 200, {}
        end

        def fetch_marketplace_guides
          @@marketplace_guides = Rails.cache.fetch('marketplace_guides', expires_in: 60.minutes) do
            marketplace_guides = HashWithIndifferentAccess.new
            MarketplaceGuide.all.each do |guide|
              marketplace_guides[guide[:guide_id]] = guide.attributes
            end
            marketplace_guides
          end
        end
      end
    end
  end
end
