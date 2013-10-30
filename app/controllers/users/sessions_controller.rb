class Users::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable
  def new
    flash[:notice] = params[:notice] if params[:notice]
    self.resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    if params[:email]
      @signin_message = 'Looks like you already have an account!'
      self.resource.email = params[:email]
    end
    respond_with(resource, serialize_options(resource))
    logger.debug '+++++++++++++++++++'
    logger.debug "Request Referer: #{request.referer}"
    logger.debug "Root Url: #{root_url}"
    logger.debug '+++++++++++++++++++'
    if session[:force_return_to] 
      session[:user_return_to] = session[:force_return_to]
      session[:force_return_to] = nil
    elsif request.referer && URI(request.referer).host == URI(root_url).host
      session[:user_return_to] = request.referer
    else
      session[:user_return_to] = root_url
    end
    logger.debug "Session Return To: #{session[:user_return_to]}"
  end

  def create
    cookies[:returning_visitor] = true
    super
    remember_me(current_user)
    mixpanel.track(current_user.email, 'Signed In')
    mixpanel.people.increment(current_user.email, {'Signed In Count' => 1})
  end

  def signin_and_enroll
    @user = User.find_for_authentication(email: params[:email])
    @course = Course.find(params[:course_id])
    if @user.valid_password?(params[:password])
      sign_in @user
      mixpanel.track(current_user.email, 'Signed In')
      mixpanel.people.increment(current_user.email, {'Signed In Count' => 1})
      @enrollment = Enrollment.new(user_id: current_user.id, enrollable: @course)
      if @enrollment.save
        redirect_to course_url(@course), notice: "You are now enrolled into the #{@course.title} Course!"
        track_event @course, 'enroll'
        mixpanel.people.append(current_user.email, {'Classes Enrolled' => @course.title})
        finished('poutine', :reset => false)
        finished('free or not', :reset => false)
      else
        redirect_to course_url(@course), notice: "Sign in successful!"
      end
    else
      redirect_to course_url(@course), notice: 'Incorrect password.'
    end
  end

end