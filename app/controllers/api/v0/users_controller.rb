module Api
  module V0
    class UsersController < BaseController

      # Required since this only this controller contains the code to actually
      # set the cookie and not just generate the token
      include Devise::Controllers::Rememberable
      before_filter :ensure_authorized, except: [:create]

      def me
        @user = User.find @user_id_from_token

        remember_me @user # sets remember_user_token cookie
        warden.set_user @user # sets session cookie, unsure if this is necessary

        if @user
          method_includes = [:avatar_url, :encrypted_bloom_info]
          # Don't leak admin flag if user is not admin
          if @user.admin?
            method_includes << :admin
          end

          @user[:intercom_user_hash] = ApplicationController.new.intercom_user_hash(@user)

          render json: @user.to_json(only: [:id, :name, :slug, :email, :intercom_user_hash, :needs_special_terms], methods: method_includes), status:200
        else
          render json: {status: 501, message: 'User not found.'}, status: 501
        end
      end

      def create
        params[:source] ||= "api_standard"
        # TODO - deprecate this branch completely, in the short-run we need to
        # verify that this branch is not used.
        if params[:user][:provider] && params[:user][:provider] == 'facebook'
          render_unauthorized
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

      def shown_terms
        @user = User.find @user_id_from_token
        @user.was_shown_terms
        render json: {status: 200}, status: 200
      end

      private

      # Why is this code duplicated here?
      def create_new_user(user)
        if user.save
          email_list_signup(user.name, user.email, params[:source])
          aa = ActorAddress.create_for_user @user, client_metadata: "create"
          # mixpanel.alias needs to be called with @user.id instead of @user.email for consistant tracking with the client
          mixpanel.alias(@user.id, mixpanel_anonymous_id) if mixpanel_anonymous_id
          mixpanel.track(@user.id, 'Signed Up', {source: 'api'})
          Resque.enqueue(Forum, 'update_user', Rails.application.config.shared_config[:bloom][:api_endpoint], user.id)
          Librato.increment 'user.signup', sporadic: true
          render json: {status: 200, message: 'Success', token: aa.current_token.to_jwt}, status: 200
        else
          logger.warn "create_new_user errors: #{user.errors.inspect}"
          render json: {status: 400, message: 'Bad Request: An error occured when trying to create this user.'}, status: 400
        end
      end
    end
  end
end
