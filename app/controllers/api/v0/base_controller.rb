module Api
  module V0
    class BaseController < ActionController::Base

      protected

      def ensure_authorized
        begin
          decoded = JWT.decode(params[:token_auth], 'SomeSecret')
          user = User.find decoded['user']['id']
        rescue JWT::DecodeError, StandardError
          render json: {status: '401 Unauthorized'}, status: 401
        end

      end
    end
  end
end