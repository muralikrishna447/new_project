class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable

  skip_before_filter :authenticate_cors_user

  # def facebook
  #   auth = request.env["omniauth.auth"]
  #   @user = User.facebook_connected_user(auth)

  #   if @user
  #     sign_in_and_redirect @user, event: :authentication
  #   else
  #     session["devise.facebook_data"] = auth
  #     redirect_to complete_registration_url(@user)
  #   end
  # end

  def facebook
    unless request.xhr?
      standard_login
    else
      @user = User.facebook_connect(params[:user])
      javascript_login
    end
  end

  def google
    unless request.xhr?
      standard_login
    else
      user_options = User.gather_info_from_google(params, google_app_id, google_secret)
      if current_user
        current_user.google_connect(user_options)
        return render status: 200, json: {success: true, new_user: false, info: "Associated account", user: current_user.to_json(include: :enrollments)}
      else
        @user = User.google_connect(user_options)
        javascript_login
      end
    end
  end


private

  def standard_login #old method for facebook
    auth = request.env["omniauth.auth"]
    @user = User.facebook_connected_user(auth)

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
      if @new_signup
        # Trigger as a signup
        sign_in @user
        aweber_signup(@user.name, @user.email)
        cookies.delete(:viewed_activities)
        cookies[:returning_visitor] = true
        mixpanel.alias(@user.email, mixpanel_anonymous_id)
        mixpanel.track(@user.email, 'Signed Up')
        return render status: 200, json: {success: true, new_user: @new_signup, info: "Signed Up", user: current_user.to_json(include: :enrollments)}
      else
        # Trigger as a login
        sign_in @user
        remember_me(current_user)
        mixpanel.track(current_user.email, 'Signed In')
        mixpanel.people.increment(current_user.email, {'Signed In Count' => 1})
        return render status: 200, json: {success: true, new_user: @new_signup, info: "Logged in", user: current_user.to_json(include: :enrollments)}
      end
    end
  end



end
