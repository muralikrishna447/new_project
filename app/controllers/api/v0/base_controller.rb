module Api
  module V0
    class BaseController < ActionController::Base
      protected
      def ensure_authorized
        if params[:token_auth]
          begin
            decoded = JWT.decode(params[:token_auth], "SomeSecret")
            parsed = JSON.parse(decoded)
            user = User.find(parsed.user.id)
            if user.valid_password?(parsed.user.password)

            else
              render json: {status: '401 Unauthorized'}, status: 401
            end
          rescue JWT::DecodeError
            render json: {status: '400 Bad Request'}, status: 400
          end
        else
          render json: {status: '401 Unauthorized'}, status: 401
        end
      end
    end
  end
end