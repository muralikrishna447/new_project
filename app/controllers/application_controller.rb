class ApplicationController < ActionController::Base
  include StatusHelpers
  protect_from_forgery

  if Rails.env.angular? || Rails.env.development?
    require 'database_cleaner'
    def start_clean
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
      render nothing: true
    end
    def end_clean
      DatabaseCleaner.clean
      render nothing: true
    end
  end

  # For dynamically setting the host to whatever it needs to be for the environment we're testing.
  before_filter :set_mailer_host
  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end


  expose(:version) { Version.current }
  expose(:current_user_presenter) { current_user.present? ? UserPresenter.new(current_user) : nil }

  def global_navigation
    render partial: 'layouts/header', :locals => { :external => true }
  end

  def options
    render :text => '', :content_type => 'text/plain'
  end

  # expose devise helper method to views
  helper_method :after_sign_in_path_for

  # On sign in, if profile isn't complete, nudge them to finish it now
  # def after_sign_in_path_for(user)
  #   return super(user) if user.admin? || user.profile_complete?
  #   super(user)
  #   user_profile_path(user)
  # end

  def after_sign_in_path_for(resource)
    # if request.referer == sign_in_url
    #   super
    # else
    #   stored_location_for(resource) || request.referer || user_profile_path(resource)
    # end
    if request.referer == sign_in_url
      super
    else
      if request.referer && URI(request.referer).host == URI(root_url).host && request.referer != sign_in_url && request.referer != new_user_session_url
        stored_location_for(resource) || request.referer || user_profile_path(resource)
      else
        root_url
      end
    end
  end

  def authenticate_active_admin_user!
    authenticate_user!
    unless current_user.role?(:contractor)
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
    end
  end

  helper_method :facebook_app_id
  def facebook_app_id
    case Rails.env
    when "production"
      "380147598730003"
    when "staging", "staging2"
      "642634055780525"
    else
      "249352241894051"
    end
  end

  helper_method :facebook_secret
  def facebook_secret
    case Rails.env
    when "production"
      ENV["FACEBOOK_SECRET"]
    when "staging", "staging2"
      "1cb4115088bd42aed2dc6d9d11c82930"
    else
      "57601926064dbde72d57fedd0af8914f"
    end
  end

  helper_method :google_app_id
  def google_app_id
    case Rails.env
    when "production"
      ENV["GOOGLE_APP_ID"]
    when "staging", "staging2"
      ENV["GOOGLE_APP_ID"]
    else
      "108479453177.apps.googleusercontent.com"
      # "73963737070-9595b3hcj6kqpii3trkg398m4q5duck5.apps.googleusercontent.com"
    end
  end

  helper_method :google_secret
  def google_secret
    case Rails.env
    when "production"
      ENV["GOOGLE_SECRET"]
    when "staging", "staging2"
      ENV["GOOGLE_SECRET"]
    else
      "M2Y-HWIkTVPNHLUS1P_QNKHr"
      # "GDEp3Pw_vGew3dorCkurox8U"
    end
  end


private

  def track_event(trackable, action = params[:action])
    if current_user
      current_user.events.create! action: action, trackable: trackable
    end
  end

  def track_receiver_event(trackable, action = params[:action])
    puts trackable.receiver.inspect
    if trackable.receiver
      new_event = trackable.receiver.events.create! action: "received_#{action}", trackable: trackable
      puts new_event.inspect
    end
  end

  def mixpanel
    if Rails.env.production?
      @mixpanel ||= Mixpanel::Tracker.new '84272cf32ff65b70b86639dacd53c0e0'
    else
      @mixpanel ||= Mixpanel::Tracker.new 'd6d82f805f7d8a138228a52f17d6aaec'
    end
  end

  def mixpanel_anonymous_id
    begin
      JSON.parse(cookies["mp_#{mixpanel.instance_variable_get('@token')}_mixpanel"])['distinct_id']
    rescue
      id = request.session_options[:id]
      cookies["mp_#{mixpanel.instance_variable_get('@token')}_mixpanel"] = {distinct_id: id}.to_json
      id
    end
  end

  # See http://stackoverflow.com/questions/14734243/rails-csrf-protection-angular-js-protect-from-forgery-makes-me-to-log-out-on
  after_filter  :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  before_filter :set_share_a_sale
  def set_share_a_sale
    if params[:SSAID].present? && params[:SSAIDDATA].present?
      cookies['SSAID'] = params[:SSAID]
      cookies['SSAIDDATA'] = params[:SSAIDDATA]
    end
  end

  before_filter :get_escaped_fragment_from_brombone
  def get_escaped_fragment_from_brombone
    if params.has_key?(:'_escaped_fragment_')
      puts "Rendering #{request.path} from brombone snapshot"
      base_url = "http://chefsteps.brombonesnapshots.com/www.chefsteps.com#{request.path}"
      uri = URI.parse(base_url)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      puts response.inspect
      if response.code.to_i == 200
        render text: response.body
      else
        puts "Brombone returned #{response.code} for #{request.path} - falling back to standard page"
      end
    end
  end

  def email_list_signup(name, email, source='unknown', listname='a61ebdcaa6')
    begin
      Gibbon::API.lists.subscribe(
        id: listname,
        email: {email: email},
        merge_vars: {NAME: name, SOURCE: source},
        double_optin: false,
        send_welcome: false
      )

    rescue Exception => e
      case Rails.env
      when "production", "staging", "staging2"
        logger.error("MailChimp error: #{e.message}")
        raise e unless e.message.include?("already subscribed to list")
      else
        logger.debug("MailChimp error, ignoring - did you set MAILCHIMP_API_KEY? Message: #{e.message}")
      end
    end
  end

  # http://nils-blum-oeste.net/cors-api-with-oauth2-authentication-using-rails-and-angularjs/
  # do not use CSRF for CORS options
  skip_before_filter :verify_authenticity_token, :only => [:options]

  before_filter :cors_set_access_control_headers
  # before_filter :authenticate_cors_user

  def authenticate_cors_user
    if request.xhr? && !user_signed_in?
      error = { :error => "You must be logged in." }
      render :json => error, :status => 401
    end
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*, X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def set_referrer_in_mixpanel(key)
    if session[:referred_from] && session[:referred_by]
      referrer = User.find(session[:referred_by])
      mixpanel.people.increment(referrer.email, {key => 1})
    end
  end

  def from_ios_app?
    (params[:client] == "iOS")
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
  end

end

