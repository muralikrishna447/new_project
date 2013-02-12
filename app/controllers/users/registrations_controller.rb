class Users::RegistrationsController < Devise::RegistrationsController
  append_after_filter :aweber_signup, :only => :create

  def new
    email = params[:email]
    @user = User.where(email: email).first
    if @user
      if @user.from_aweber
        redirect_to new_user_password_url(email: email, aw: true)
      else
        redirect_to sign_in_url(email: email)
      end
    else
      @user = User.new
      @user.email = email
    end
  end

  def complete_registration
    @user = User.new
  end

  protected
  def build_resource(hash=nil)
    hash ||= resource_params || {}
    self.resource = resource_class.new_with_session(hash, session)

    fb_data = session["devise.facebook_data"]
    self.resource.assign_from_facebook(fb_data) if fb_data
  end

  def aweber_signup
    if params[:ok_to_email] && Rails.env.production?
      uri = URI.parse("http://www.aweber.com/scripts/addlead.pl")
      response = Net::HTTP.post_form(uri,
                                      { "email" => params[:user][:email],
                                        "name" => params[:user][:name],
                                        "listname" => "cs_c_sousvide",
                                        "meta_adtracking" => "cs_new_site_user"})
    else
      puts 'AWEBER SIGNUP'
    end
  end

  def after_sign_up_path_for(resource)
    request.referrer
  end
end

