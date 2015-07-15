module Api
  module V0
    class UsersController < BaseController
      before_filter :ensure_authorized, except: [:create]

      def me
        @user = User.find @user_id_from_token

        if @user
          method_includes = [:avatar_url]
          # Don't leak admin flag if user is not admin
          if @user.admin?
            method_includes << :admin
          end

          render json: @user.to_json(only: [:id, :name, :slug, :email], methods: method_includes), status:200
        else
          render json: {status: 501, message: 'User not found.'}, status: 501
        end
      end

      def index
        per = params[:per] ? params[:per] : 12
        @users = User.page(params[:page]).per(per)
        render json: @users.to_json(only: [:id, :name, :slug], methods: :avatar_url)
      end

      def create
        params[:source] ||= "api_standard"
        if params[:user][:provider] && params[:user][:provider] == 'facebook'
          is_new_user = User.find_by_email(params[:user][:email]).blank?
          @user = User.facebook_connect(params[:user])
          if is_new_user
            create_new_user(@user)
          else
            aa = ActorAddress.create_for_user @user, client_metadata: "create"
            render json: {status: 200, message: 'Success', token: aa.current_token.to_jwt}, status: 200
          end
        else
          @user = User.new(params[:user])
          create_new_user(@user)
        end
      end

      def update
        @user = User.find params[:id]
        if @user_id_from_token == @user.id
          logger.info "Updating user #{@user.inspect}"
          logger.info "Updating with: #{params[:user]}"
          if @user.update_attributes(params[:user])
            render json: @user.to_json(only: [:id, :name, :slug, :email], methods: :avatar_url), status: 200
          else
            render json: {status: 400, message: "Bad Request.  Could not update user with params #{params[:user]}"}, status: 400
          end
        else
          render json: {status: 401, message: 'Unauthorized.', debug: "From token: #{@user_id_from_token}, ID: #{@user.id}"}, status: 401
        end
      end

      private

      # Why is this code duplicated here?
      def create_new_user(user)
        if user.save
          email_list_signup(user.name, user.email, params[:source])
          aa = ActorAddress.create_for_user @user, client_metadata: "create"
          render json: {status: 200, message: 'Success', token: aa.current_token.to_jwt}, status: 200
        else
          render json: {status: 400, message: 'Bad Request: An error occured when trying to create this user.'}, status: 400
        end
      end
    end
  end
end
