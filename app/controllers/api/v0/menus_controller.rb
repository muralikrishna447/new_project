module Api
  module V0
    class MenusController < BaseController

      def list
        menus = Menu.get_menus(fetch_user_permission.to_sym)
        render json: menus
      end

      private

      def fetch_user_permission
        token = request.authorization&.split(' ')&.last
        user = if token.present? && token != 'null'
                 current_token = AuthToken.from_string(token)
                 ActorAddress.find_for_token(current_token).try(:actor)
               end
        return 'not_logged' unless user.present?
        return 'admin' if user.admin?
        return 'studio' if user.studio?
        return 'premium' if user.premium_member?
        'free'
      end
    end
  end
end
