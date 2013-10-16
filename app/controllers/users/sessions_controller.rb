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
    if request.referer && URI(request.referer).host == URI(root_url).host
      session[:user_return_to] = request.referer
    else
      session[:user_return_to] = root_url
    end
    logger.debug "Session Return To: #{session[:user_return_to]}"
  end

  def create
    cookies[:returning_visitor] = true
    unless request.xhr?
      super
      remember_and_track
    else
      resource = warden.authenticate!(:scope => :user, :recall => "#{controller_path}#failure")
      sign_in_and_redirect(:user, resource)
    end
  end

  def signin_and_enroll
    @user = User.find_for_authentication(email: params[:email])
    @course = Course.find(params[:course_id])
    if @user.valid_password?(params[:password])
      sign_in @user
      mixpanel.track 'Signed In', { distinct_id: @user.email }
      mixpanel.append_identify @user.email
      @enrollment = Enrollment.new(user_id: current_user.id, enrollable: @course)
      if @enrollment.save
        redirect_to course_url(@course), notice: "You are now enrolled into the #{@course.title} Course!"
        track_event @course, 'enroll'
        finished('poutine', :reset => false)
        finished('free or not', :reset => false)
      else
        redirect_to course_url(@course), notice: "Sign in successful!"
      end
    else
      redirect_to course_url(@course), notice: 'Incorrect password.'
    end
  end

  private
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    remember_and_track
    return render status: 200, json: {success: true, info: "Logged in", user: current_user}
  end

  def remember_and_track
    remember_me(current_user)
    mixpanel.track 'Signed In', { distinct_id: current_user.email }
    mixpanel.append_identify current_user.email
    mixpanel.increment 'Signed In Count'
  end

end