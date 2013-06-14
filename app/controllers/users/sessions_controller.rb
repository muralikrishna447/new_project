class Users::SessionsController < Devise::SessionsController

  def new
    self.resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    if params[:email]
      @signin_message = 'Looks like you already have an account!'
      self.resource.email = params[:email]
    end
    respond_with(resource, serialize_options(resource))
  end

  def create
    cookies[:returning_visitor] = true
    super
    mixpanel.track 'Signed In', { distinct_id: current_user.id }
  end

  def signin_and_enroll
    @user = User.find_for_authentication(email: params[:email])
    @course = Course.find(params[:course_id])
    if @user.valid_password?(params[:password])
      sign_in @user
      mixpanel.track 'Signed In', { distinct_id: @user.id }
      @enrollment = Enrollment.new(user_id: current_user.id, course_id: @course.id)
      if @enrollment.save
        redirect_to course_url(@course), notice: "You are now enrolled into the #{@course.title} Course!"
        track_event @course, 'enroll'
        finished('spherification', :reset => false)
        mixpanel.track 'Course Enrolled', { course: @course.title, enrollment_method: 'Sign In and Enroll' }
      else
        redirect_to course_url(@course), notice: "Sign in successful!"
      end
    else
      redirect_to course_url(@course), notice: 'Incorrect password.'
    end
  end

end