module Api::V0
  class PasswordsController < BaseController
    before_filter :ensure_authorized, only: [:update]
    before_filter :ensure_password_token, only: [:update_from_reset]

    def update
      @user = User.find params[:id]
      if @user.valid_password?(params[:current_password]) && @user.update_attribute(:password, params[:new_password])
        render json: { status: '200 Success'}, status: 200
      else
        render json: {status: '401 Unauthorized'}, status: 401
      end
    end

    def update_from_reset
      @user = User.find params[:id]
      if @user.update_attribute(:password, params[:new_password])
        render json: { status: '200 Success'}, status: 200
      else
        render json: {status: '401 Unauthorized'}, status: 401
      end
    end

    def reset
      @user = User.find_by_email params[:email]
      exp = ((Time.now + 1.day).to_f * 1000).to_i
      token = create_token(@user, exp, 'Password Reset')
      if @user
        UserMailer.reset_password("huy@chefsteps.com", token).deliver
        render json: { status: '200 Success'}, status: 200
      else
        render json: {status: '401 Unauthorized'}, status: 401
      end
    end

    private

    def ensure_password_token
      if !params[:token] || !valid_token?(params[:token], 'Password Reset')
        render json: {status: '401 Unauthorized'}, status: 401
      end
    end
  end
end