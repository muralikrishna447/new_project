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
          render json: @user, serializer: Api::UserMeSerializer
        else
          render json: {status: 501, message: 'User not found.'}, status: 501
        end
      end

      def create
        optout = (params[:optout] && params[:optout]=="true") #email list optout
        params[:source] ||= "api_standard"
        # TODO - deprecate this branch completely, in the short-run we need to
        # verify that this branch is not used.
        if params[:user][:provider] && params[:user][:provider] == 'facebook'
          render_unauthorized
        else
          @user = User.new(params[:user])
          create_new_user(@user, optout, params[:source])
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

      def international_joule
        # ECOMMTODO Do mailchimp stuff
        @user = User.find @user_id_from_token
        # Something like this
        # email_list_add_to_group(@user.email, '8061', ['international_joule'])
        render json: {}, code: :ok
      end

      private

      # Why is this code duplicated here?
      def create_new_user(user, optout, source)
        if user.save
          aa = ActorAddress.create_for_user @user, client_metadata: "create"
          subscribe_and_track user, optout, source

          render json: {status: 200, message: 'Success', token: aa.current_token.to_jwt}, status: 200
        else
          logger.warn "create_new_user errors: #{user.errors.inspect}"
          render json: {status: 400, message: 'Bad Request: An error occured when trying to create this user.'}, status: 400
        end
      end
    end
  end
end
