module Api
  module V0
    class AuthController < BaseController
      def authenticate
        puts "AUTHENtICATE ACTION"
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
          render json: {status: "401 Unauthorized user: #{user.inspect}, u: #{params[:user]}"}, status: 401
        end
      end

    end
  end
end