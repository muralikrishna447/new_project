module Api
  module V0
    module Shopping
      class MarketplaceController < BaseController
        STEAK_GUIDE_ID = '2MH313EsysIOwGcMooSSkk'
        before_filter :ensure_authorized_or_anonymous

        @@marketplace_guides = {
          '3N1qPSrcViOGEYCeaG6io4' => {
              url: "https://#{Rails.configuration.shopify[:store_domain]}/products/snake-river-farms-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
              button_text: 'Shop steaks'
          },
          '6h1aaoAJcAeGuoAgQs28kw' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/snake-river-farms-kurobuta-pork-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop pork',
          },
          '1EufIMhjAMmc0UoWyEOmIs' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/double-r-ranch-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop steaks',
          },
          'pBOwIfZdDiOeo4egsUg0C' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/snake-river-farms-kurobuta-pork-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop pork',
          },
          '6U0Sv3hcDm06oCk0W8iO6m' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/double-r-ranch-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop steaks',
          },
          '6ORApkpQQ04IcKse0qIW8k' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/snake-river-farms-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop steaks',
          }
        }


        def guide_button
          guide_id = params[:guide_id]
          if @@marketplace_guides[guide_id]
            Rails.logger.info "Matching marketplace guide"
            button_text = @@marketplace_guides[guide_id][:button_text]
            return render_api_response 200, {button: {line_1: button_text}}
          end

          if @user_id_from_token.nil?
            Rails.logger.info "User not logged in - showing no button"
            return render_no_button
          end

          if params[:guide_id] != STEAK_GUIDE_ID
            Rails.logger.info "Steak guide not selected - showing no button"
            return render_no_button
          end

          if BetaFeatureService.user_has_feature(current_api_user, 'steak_buy_button')
            return render_api_response 200, {button: {line_1: "Buy locally", line_2: "$20-$40"}}
          end
          return render_no_button
        end

        def guide_button_redirect
          guide_id = params[:guide_id]
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
      end
    end
  end
end
