module Api
  module V0
    class BaseController < ActionController::Base
      def current_user
        return nil unless params[:auth_token]
        User.find_by_token(params[:auth_token])
      end
    end
  end
end