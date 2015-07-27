class Users::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  skip_before_filter :require_no_authentication, on: :create, if: proc {|c| request.xhr?}

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
    unless request.xhr?
      super
      remember_and_track
    else
      resource = warden.authenticate!(:scope => :user, :recall => "#{controller_path}#failure")
      sign_in_and_redirect(:user, resource)
    end
  end

  def failure
    render :status => 401, :json => { :success => false, :errors => "Invalid email or password"}
  end

  def destroy
    # Delete persisted _chefsteps_token on logout
    cookies.delete :_chefsteps_token

    unless request.xhr?
      super
    else
      current_user.reset_authentication_token!
      return render status: 200, json: {success: true, info: "Logged Out"}
    end
  end

  private
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    current_user.ensure_authentication_token!  #make sure the user has a token generated
    remember_and_track
    return render status: 200, json: {success: true, info: "Logged in", user: current_user.to_json(methods: :authentication_token, include: [:enrollments])}
  end

  def remember_and_track
    remember_me(current_user)
    mixpanel.track(current_user.email, 'Signed In')
  end

end
