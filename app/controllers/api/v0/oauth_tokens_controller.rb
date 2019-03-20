module Api
  module V0
    class OauthTokensController < BaseController
      before_filter :ensure_authorized
      
      def index
        user = User.find @user_id_from_token

        unless user
          return render_api_response 404, {:message => "User not found"}
        end

        render_api_response 200, user.oauth_tokens
      end

    end
  end
end
