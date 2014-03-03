class TokensController < ActionController::Metal
  include ActionController::Rendering
  def verify
    @user = User.find_by_id(params[:id])
    if params[:auth_token] && @user && @user.authentication_token == params[:auth_token]
      render text: 'success', status: 200
    else
      render text: 'unauthorized', status: 401
    end
  end
end