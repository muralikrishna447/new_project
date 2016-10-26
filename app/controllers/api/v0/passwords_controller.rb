module Api
  module V0
    class PasswordsController < BaseController
      before_filter :ensure_authorized, only: [:update]
      before_filter :ensure_password_token, only: [:update_from_email]

      def update
        Librato.increment("api.password_update_requests")
        @user = User.find params[:id]
        logger.info "Attempting to update password: #{@user.email}"
        if @user.valid_password?(params[:current_password]) && @user.update_attribute(:password, params[:new_password])
          render json: { status: 200, message: 'Success'}, status: 200
        else
          render_unauthorized
        end
      end

      def update_from_email
        Librato.increment("api.password_update_from_email_requests")
        @user = User.find_by_email @user_email
        logger.info "Attempting to update password from email: #{@user_email}"

        @user.password = params[:password]

        begin
          @user.save!
          render json: { status: 200, message: 'Success'}, status: 200
        rescue ActiveRecord::RecordInvalid => e
          logger.error "Could not save user password: #{e}"
          render json: { status: 400, message: 'Could not save password'}, status: 400
        end
      end

      def send_reset_email
        Librato.increment("api.password_send_reset_email_requests")
        @user = User.find_by_email params[:email]
        if @user
          logger.info "Sending password reset email for: #{@user.email}"
          aa = ActorAddress.create_for_user @user, client_metadata: "password_reset"

          exp = ((Time.now + 1.day).to_f * 1000).to_i
          token = aa.current_token(exp: exp, restrict_to: 'password reset').to_jwt
          UserMailer.reset_password(@user.email, token).deliver
          render json: { status: 200, message: 'Success'}, status: 200
        else
          render_unauthorized
        end
      end

      private

      def ensure_password_token
        unless params[:token]
          logger.info "No token supplied"
          render_unauthorized
          return
        end

        token = AuthToken.from_string(params[:token])
        aa = ActorAddress.find_for_token token
        unless aa.valid_token? token, sequence_offset=0, restrict_to = "password reset"
          render_unauthorized
          return
        end

        @user_email = aa.actor.email
      end
    end
  end
end
