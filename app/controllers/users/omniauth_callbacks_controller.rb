class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable


  def facebook
    unless request.xhr?
      standard_login
    else
      if current_user
        current_user.facebook_connect(params[:user])
        return render status: 200, json: {success: true, new_user: false, info: "Associated account", user: current_user.as_json(include: :enrollments)}
      else
        @user = User.facebook_connect(params[:user])
        set_referrer
        javascript_login
      end
    end
  end

  def google
    unless request.xhr?
      standard_login
    else
      user_options = User.gather_info_from_google(params, google_app_id, google_secret)
      if current_user
        current_user.google_connect(user_options)
        return render status: 200, json: {success: true, new_user: false, info: "Associated account", user: current_user.as_json(include: :enrollments)}
      else
        @user = User.google_connect(user_options)
        set_referrer
        javascript_login
      end
    end
  end

  def destroy
    current_user.disconnect_service!(params[:service])
    return render status: 200, json: {success: true, info: "Disassociated Account", user: current_user.as_json(include: :enrollments)}
  end


private

  def set_referrer
    if @user
      @user.referrer_id = session[:referrer_id]
      @user.referred_from = session[:referred_from]
    end
  end

  def standard_login #old method for facebook
    auth = request.env["omniauth.auth"]
    @user = User.facebook_connected_user(auth)
    set_referrer
    if @user
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.facebook_data"] = auth
      redirect_to complete_registration_url(@user)
    end
  end

  def javascript_login
    @new_signup = @user.new_record?
    if @user.save
      @user.ensure_authentication_token!
      if @new_signup
        sign_in @user
        cookies.delete(:viewed_activities)
        subscribe_and_track @user, @user.opt_in, "ajax_signup_form_social"

        return render status: 200, json: {success: true, new_user: @new_signup, info: "Signed Up", user: current_user.as_json(include: :enrollments)}
      else
        # Trigger as a login
        sign_in @user
        remember_me(current_user)
        return render status: 200, json: {success: true, new_user: @new_signup, info: "Logged in", user: current_user.as_json(include: :enrollments)}
      end
    end
  end



end
