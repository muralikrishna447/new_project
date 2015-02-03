module Api
  module V0
    class AuthController < ActionController::Base
      def authenticate
        begin
          user = User.find_by_email(params[:email])
          if user.valid_password?(params[:password])
            exp = ((Time.now + 1.year).to_f * 1000).to_i
            payload = { 
              exp: exp,
              user: user
            }
            token = JWT.encode(payload.as_json, "SomeSecret")
            render json: {token: token}, status: 200
          else
            render json: {status: '401 Unauthorized'}, status: 401
          end
        rescue Exception => e
          puts "Exception: "
          puts e
          render json: {status: '400 Bad Request'}, status: 400
        end
      end
    end
  end
end