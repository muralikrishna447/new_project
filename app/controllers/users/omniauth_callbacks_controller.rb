class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable
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
      auth = request.env["omniauth.auth"]
      @user = User.facebook_connected_user(auth)

      if @user
        sign_in_and_redirect @user, event: :authentication
      else
        session["devise.facebook_data"] = auth
        redirect_to complete_registration_url(@user)
      end
    else
      @user = User.facebook_connect(params[:user])
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

  protected

  def aweber_signup(name, email, signed_up_from=nil, listname='cs_c_sousvide', meta_adtracking='site_top_form')
    if Rails.env.production?
      uri = URI.parse("http://www.aweber.com/scripts/addlead.pl")
      response = Net::HTTP.post_form(uri,
                                      { "name" => name,
                                        "email" => email,
                                        "listname" => listname,
                                        "meta_adtracking" => meta_adtracking,
                                        "custom signed_up_from" => signed_up_from})
    else
      logger.debug 'Newsletter Signup'
    end
  end
end
