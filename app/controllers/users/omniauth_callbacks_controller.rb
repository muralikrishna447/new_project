class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.connect_user_with_facebook(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      session["devise.unconfirmed_user"] = @user
      redirect_to root_url(anchor: 'complete-registration')
    end
  end
end
