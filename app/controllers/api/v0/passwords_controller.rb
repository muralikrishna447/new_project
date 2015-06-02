module Api::V0
  class PasswordsController < BaseController
    before_filter :ensure_authorized, only: [:update]
    before_filter :ensure_password_token, only: [:update_from_email]

    def update
      @user = User.find params[:id]
      if @user.valid_password?(params[:current_password]) && @user.update_attribute(:password, params[:new_password])
        render json: { status: 200, message: 'Success'}, status: 200
      else
        render_unauthorized
      end
    end

    def update_from_email
      @user = User.find_by_email @user_email
      @user.password = params[:password]
      if @user.save!
        render json: { status: 200, message: 'Success'}, status: 200
      else
        render_unauthorized
      end
    end

    def send_reset_email
      @user = User.find_by_email params[:email]
      if @user
        aa = ActorAddress.create_for_user @user, 'password_reset'

        exp = ((Time.now + 1.day).to_f * 1000).to_i
        token = aa.current_token(exp = exp, restrict_to = 'password reset').to_jwt
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
