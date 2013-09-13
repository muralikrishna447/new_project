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
      # redirect_to user_profile_path(@user), notice: "Thanks for signing up! Please check your email now to confirm your registration."
      puts "Return path " + session[:user_return_to]
      if session[:user_return_to] && (session[:user_return_to] != root_url)
        redirect_to session[:user_return_to], notice: "Thanks for signing up! Please check your email now to confirm your registration."
      else
        redirect_to welcome_url(email: @user.email)
      end
      cookies.delete(:viewed_activities)
      cookies[:returning_visitor] = true
      mixpanel.append_identify @user.email
      mixpanel.track 'Signed Up', { distinct_id: @user.email, time: @user.created_at }
      finished('counter_split', :reset => false)
    else
      render :new
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
      mixpanel.append_identify @user.email
      mixpanel.track 'Signed Up', { distinct_id: @user.email, time: @user.created_at }
      @enrollment = Enrollment.new(user_id: current_user.id, enrollable: @course)
      if @enrollment.save
        redirect_to course_url(@course), notice: "Thanks for enrolling! Please check your email now to confirm your registration."
        track_event @course, 'enroll'
        finished('poutine', :reset => false)
        finished('free or not', :reset => false)
        mixpanel.track 'Course Enrolled', { distinct_id: @user.email, course: @course.title, enrollment_method: 'Sign Up and Enroll' }
        mixpanel.increment 'Course Enrolled Count'

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

  def after_sign_up_path_for(resource)
    if URI(request.referer).path == complete_registration_path
      root_url
    else
      request.referrer
    end
  end
end

