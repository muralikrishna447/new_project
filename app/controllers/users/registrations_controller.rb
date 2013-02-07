class Users::RegistrationsController < Devise::RegistrationsController
  append_after_filter :aweber_signup, :only => :create

  def new
    email = params[:email]
    @user = User.where(email: email)
    if @user.any?
      redirect_to sign_in_url(email: email)
    else
      @user = User.new
      @user.email = email
    end
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
end

