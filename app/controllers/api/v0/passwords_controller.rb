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
    end
  end
end