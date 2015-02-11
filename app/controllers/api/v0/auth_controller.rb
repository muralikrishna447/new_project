module Api
  module V0
    class AuthController < BaseController
      skip_before_filter :verify_authenticity_token
      before_filter :cors_preflight_check
      after_filter :cors_set_access_control_headers
      def authenticate
        begin
          user = User.find_by_email(params[:user][:email])
          if user && user.valid_password?(params[:user][:password])
            render json: {status: '200 Success', token: create_token(user)}, status: 200
          else
            render json: {status: '401 Unauthorized'}, status: 401
          end
        rescue Exception => e
          puts "Authenticate Exception: #{e.class} #{e}"
          render json: {status: '400 Bad Request'}, status: 400
        end
      end

    end
  end
end