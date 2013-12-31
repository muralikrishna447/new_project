class Users::RegistrationsController < Devise::RegistrationsController
  # append_after_filter :aweber_signup, :only => :create

  def welcome
    # name = params[:name]
    # email = params[:email]
    # signed_up_from = params[:signed_up_from]
    # @user = User.where(email: email).first
    # if @user
    #   redirect_to sign_in_url(name: name, email: email)
    # else
    #   aweber_signup(email, signed_up_from)
    # end
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
    @user = User.new(params[:user])
    if cookies[:viewed_activities]
      @user.viewed_activities = JSON.parse(cookies[:viewed_activities])
    end
    if @user.save
      sign_in @user
      aweber_signup(@user.name, @user.email)
      cookies.delete(:viewed_activities)
      cookies[:returning_visitor] = true
      mixpanel.alias(@user.email, mixpanel_anonymous_id)
      mixpanel.track(@user.email, 'Signed Up')
      finished('counter_split', :reset => false)
      unless request.xhr?
        # redirect_to user_profile_path(@user), notice: "Thanks for signing up! Please check your email now to confirm your registration."
        if session[:user_return_to] && (session[:user_return_to] != root_url && session[:user_return_to] != sign_in_url)
          redirect_to session[:user_return_to], notice: "Thanks for signing up! Please check your email now to confirm your registration."
        else
          redirect_to welcome_url(email: @user.email)
        end
      else
        return render status: 200, json: {success: true, info: "Logged in", user: @user}
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

  def signup_and_enroll
    @user = User.new(params[:user])
    @course = Course.find(params[:course_id])
    if cookies[:viewed_activities]
      @user.viewed_activities = JSON.parse(cookies[:viewed_activities])
    end
    if @user.save
      sign_in @user
      aweber_signup(@user.name, @user.email)
      cookies.delete(:viewed_activities)
      mixpanel.alias(@user.email, mixpanel_anonymous_id)
      mixpanel.track(@user.email, 'Signed Up')
      @enrollment = Enrollment.new(user_id: current_user.id, enrollable: @course)
      if @enrollment.save
        redirect_to course_url(@course), notice: "Thanks for enrolling! Please check your email now to confirm your registration."
        track_event @course, 'enroll'
        finished('poutine', :reset => false)
        finished('free or not', :reset => false)
        mixpanel.people.increment(@user.email, {'Course Enrolled Count' => 1})
        mixpanel.people.append(@user.email, {'Classes Enrolled' => @course.title})
      end
    else
      redirect_to course_url(@course), notice: "Sorry, there was a problem with the information provided.  Please try again."
    end
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

