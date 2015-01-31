module Api
  module V0
    class AuthController < ActionController::Base
      def authenticate
        begin
          user = User.find_by_email(params[:user][:email])
          if user.valid_password?(params[:user][:password])
            exp = ((Time.now + 1.year).to_f * 1000).to_i
            payload = { 
              exp: exp,
              user: {
                id: user.id,
                name: user.name,
                role: user.role
              }
            }
            token = JWT.encode(payload.as_json, "SomeSecret")
            render json: {token: token}, status: 200
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