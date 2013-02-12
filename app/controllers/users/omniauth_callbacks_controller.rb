class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    @user = User.facebook_connected_user(auth)

    if @user
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.facebook_data"] = auth
      redirect_to complete_registration_url(@user)
    end
  end
end
