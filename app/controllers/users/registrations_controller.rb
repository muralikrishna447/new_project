class Users::RegistrationsController < Devise::RegistrationsController
  # append_after_filter :aweber_signup, :only => :create
  skip_before_filter :require_no_authentication, on: :create, if: proc {|c| request.xhr?}

  def welcome
  end

  def new
    name = params[:name]
    email = params[:email]
    @user = User.where(name: name, email: email).first
    if @user
      redirect_to sign_in_url(name: name, email: email)
    else
      @user = User.new
      @user.name = name
      @user.email = email
      @user.signed_up_from = params[:'custom signed_up_from']
    end
  end

  def create
    @user = User.new(params[:user].merge(referred_from: session[:referred_from], referrer_id: session[:referrer_id]))
    if cookies[:viewed_activities]
      @user.viewed_activities = JSON.parse(cookies[:viewed_activities])
    end
    if @user.save
      sign_in @user
      email_list_signup(@user.name, @user.email, "ajax_signup_form")
      cookies.delete(:viewed_activities)
      cookies[:returning_visitor] = true
      mixpanel.alias(@user.email, mixpanel_anonymous_id) if mixpanel_anonymous_id
      mixpanel.track(@user.email, 'Signed Up')
      finished('counter_split', :reset => false)
      unless request.xhr?
        if session[:user_return_to] && (session[:user_return_to] != root_url && session[:user_return_to] != sign_in_url)
          redirect_to session[:user_return_to], notice: "Thanks for joining the ChefSteps community!"
        else
          redirect_to welcome_url(email: @user.email)
        end
      else
        return render status: 200, json: {success: true, info: "Logged in", user: @user.to_json(methods: :authentication_token, include: [:enrollments])}
      end
    else
      unless request.xhr?
        render :new
      else
        render status: 401, json: {success: false, info: "Please fix the errors below", errors: @user.errors}
      end
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

  def after_sign_up_path_for(resource)
    if URI(request.referer).path == complete_registration_path
      root_url
    else
      request.referrer
    end
  end
end

