module Api
  module V0
    class AuthController < ActionController::Base
      def authenticate
        begin
          user = User.find_by_email(params[:user][:email])
          if user.valid_password?(params[:user][:password])
            render json: {token: "Some Token"}, status: 200
          else
            render json: {status: '401 Unauthorized'}, status: 401
          end
        rescue
          render json: {status: '400 Bad Request'}, status: 400
        end
      end
    end
  end
end