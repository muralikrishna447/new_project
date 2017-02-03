module Api
  module V0
    module Shopping
      class MarketplaceController < BaseController
        STEAK_GUIDE_ID = '2MH313EsysIOwGcMooSSkk'
        before_filter :ensure_authorized_or_anonymous

        def guide_button
          return render_no_button if @user_id_from_token.nil?
          return render_no_button if params[:guide_id] != STEAK_GUIDE_ID

          if BetaFeatureService.user_has_feature(current_api_user, 'steak_buy_button')
            return render_api_response 200, {button: {line_1: "Buy locally", line_2: "$20-$40"}}
          end
          return render_no_button
        end

        def guide_button_redirect
          return_to = "https://#{Rails.configuration.shopify[:store_domain]}/collections/agri-beef/products/double-r-ranch-steak-selection"
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
