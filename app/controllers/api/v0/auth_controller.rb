module Api
  module V0
    class AuthController < BaseController
      before_filter :ensure_authorized, only: [:validate]

      def authenticate
        puts "AUTHENtICATE ACTION"
        begin
          user = User.find_by_email(params[:user][:email])
          if user
            if user.valid_password?(params[:user][:password])
              render json: {status: 200, message: 'Success.', token: create_token(user)}, status: 200
            else
              render json: {status: 401, message: 'Unauthorized: Password provided was invalid.'}, status: 401
            end
          else
            render json: {status: 401, message: 'Unauthorized: User was not found for email provided.'}, status: 401
          end
        rescue Exception => e
          puts "Authenticate Exception: #{e.class} #{e}"
          render json: {status: 400, message: 'Bad Request: There was an error processing this request. Please provide a valid email and password.'}, status: 400
        end
      end

      def authenticate_facebook
        puts "USER EMAILS BEFORE"
        puts params[:user][:email]
        user = User.find_by_email(params[:user][:email])
        puts "USER EMAILS"
        puts user
        puts params[:user][:email]
        if user && user.provider == 'facebook' && user.facebook_user_id == params[:user][:user_id]
          render json: {status: '200 Success', token: create_token(user)}, status: 200
        else
          render json: {status: 401, message: 'Unauthorized.'}, status: 401
        end
      end

      def validate
        token = request.authorization().split(' ').last
        if token
          if valid_token?(token)
            render json: {status: 200, message: 'Success.', tokenValid: true}, status: 200
          end
        else
          render json: {status: 400, message: 'Bad Request: Please provide a valid token.'}, status: 400
        end
      end

    end
  end
end