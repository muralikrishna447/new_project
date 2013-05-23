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
  end

  def signin_and_enroll
    @user = User.find_for_authentication(email: params[:email])
    if @user.valid_password?(params[:password])
      @course = Course.find(params[:course_id])
      sign_in @user
      @enrollment = Enrollment.new(user_id: current_user.id, course_id: @course.id)
      if @enrollment.save
        redirect_to course_url(@course), notice: "You are now enrolled into the #{@course.title} Course!"
      end
    end
  end

end