class Users::RegistrationsController < Devise::RegistrationsController
  # append_after_filter :aweber_signup, :only => :create

  def new
    name = params[:name]
    email = params[:email]
    @user = User.where(name: name, email: email).first
    if @user
      redirect_to sign_in_url(name: name, email: email)
    else
      aweber_signup(email)
      @user = User.new
      @user.name = name
      @user.email = email
      @user.signed_up_from = params[:signed_up_from]
    end
  end

  def create
    @user = User.new(params[:user])
    if cookies[:viewed_activities]
      @user.viewed_activities = JSON.parse(cookies[:viewed_activities])
    end
    if @user.save
      sign_in @user
      aweber_signup(email)
      redirect_to user_profile_path(@user), notice: "Welcome to ChefSteps! Please check your email to confirm your registration."
      cookies.delete(:viewed_activities)
    else
      render :new
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

  def aweber_signup(email, listname='cs_c_sousvide', meta_adtracking='site_top_form')
    if Rails.env.production?
      uri = URI.parse("http://www.aweber.com/scripts/addlead.pl")
      response = Net::HTTP.post_form(uri,
                                      { "email" => email,
                                        "listname" => listname,
                                        "meta_adtracking" => meta_adtracking})
    else
      logger.debug 'Newsletter Signup'
    end
  end

  def after_sign_up_path_for(resource)
    if URI(request.referer).path == complete_registration_path
      root_url
    else
      request.referrer
    end
  end
end

