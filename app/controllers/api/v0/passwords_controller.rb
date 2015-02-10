module Api::V0
  class PasswordsController < BaseController
    def update
      @user = User.find params[:id]
      if @user.valid_password?(params[:current_password]) && @user.update_attribute(:password, params[:new_password])
        render json: { status: '200 Success'}, status: 200
      else
        render json: {status: '401 Unauthorized'}, status: 401
      end
    end

    def reset
      @user = User.find_by_email params[:email]
      # Todo Generate Real Password reset token
      token = "hello"
      if @user
        UserMailer.reset_password("huy@chefsteps.com", token).deliver
        render json: { status: '200 Success'}, status: 200
      else
        render json: {status: '401 Unauthorized'}, status: 401
      end
    end
  end
end