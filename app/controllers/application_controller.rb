require 'analytics_parametizer'
class ApplicationController < BaseApplicationController
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


  before_filter :set_analytics_cookie
  def set_analytics_cookie
    referrer = request.referrer
    cookie_value = AnalyticsParametizer.cookie_value(params, cookies, referrer)
    cookies[:utm] = {
      :value => cookie_value,
      :domain => Rails.configuration.cookie_domain
    }
  end


  # For dynamically setting the host to whatever it needs to be for the environment we're testing.
  before_filter :set_mailer_host
  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end


  expose(:version) { Version.current }
  expose(:current_user_presenter) { current_user.present? ? UserPresenter.new(current_user) : nil }

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

  helper_method :google_app_id
  def google_app_id
    case Rails.env
    when "production"
      ENV["GOOGLE_APP_ID"]
    when "staging", "staging2"
      ENV["GOOGLE_APP_ID"]
    else
      # "108479453177.apps.googleusercontent.com"
      "73963737070-9595b3hcj6kqpii3trkg398m4q5duck5.apps.googleusercontent.com"
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

  helper_method :google_simple_api_key
  def google_simple_api_key
    case Rails.env
    when "production"
      ENV["GOOGLE_SIMPLE_API_KEY"]
    when "staging", "staging2"
      ENV["GOOGLE_SIMPLE_API_KEY"]
    else
      "AIzaSyBgB1d5J7_MXWk0omalNP3W71jRJ3p7p7Y"
    end
  end

  helper_method :community_secret
  def community_secret
    case Rails.env
    when "production"
      ENV["COMMUNITY_SECRET"]
    when "staging", "staging2"
      ENV["COMMUNITY_SECRET"]
    else
      "iluvsousvideCrJIzzUcof1i1p2gDZJZZg"
    end
  end

  def default_serializer_options
    {root: false}
  end

  helper_method :intercom_app_id
  def intercom_app_id
    Rails.configuration.intercom[:app_id]
  end

  helper_method :intercom_user_hash
  def intercom_user_hash(user)
    Digest::HMAC.hexdigest(user.id.to_s, Rails.configuration.intercom[:secret], Digest::SHA256)
  end

private

  def track_event(trackable, action = params[:action])
    if current_user
      current_user.events.create! action: action, trackable: trackable
    end
  end

  def track_receiver_event(trackable, action = params[:action])
    logger.info(trackable.receiver.inspect)
    if trackable.receiver
      new_event = trackable.receiver.events.create! action: "received_#{action}", trackable: trackable
      logger.info(new_event.inspect)
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

  def email_list_add_to_group(email, grouping_id, groups)
    # Reject blank group names
    groups = groups.reject{ |name| name.blank? } if groups.kind_of?(Array)

    merge_vars = {
      groupings: [
        {
          id: '8061',
          groups: groups
        }
      ]
    }

    begin
      puts "Adding user: #{email} to interest groups"
      Gibbon::API.lists.update_member(
        id: Rails.configuration.mailchimp[:list_id],
        email: { email: email },
        merge_vars: merge_vars
      )
    rescue Exception => e
      puts "Error adding user: #{email}"
      puts "Error message: #{e.message}"
    end
  end

  # http://nils-blum-oeste.net/cors-api-with-oauth2-authentication-using-rails-and-angularjs/
  # do not use CSRF for CORS options
  skip_before_filter :verify_authenticity_token, :only => [:options]


  def authenticate_cors_user
    if request.xhr? && !user_signed_in?
      error = { :error => "You must be logged in." }
      render :json => error, :status => 401
    end
  end

  def set_referrer_in_mixpanel(key)
    if session[:referred_from] && session[:referred_by]
      referrer = User.find(session[:referred_by])
    end
  end

  def from_ios_app?
    (params[:client] == "iOS")
  end

  before_filter :set_coupon
  def set_coupon
    session[:coupon] = params[:coupon] || session[:coupon]
  end

  # Moving this above fixes the issues people were having when purchasing a class.  It also allows us to get rid of the fix that was breaking commentsCount.
  # We can get rid of $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content') in chefstepsAngularInit.js.coffee that was detail in http://stackoverflow.com/questions/14734243/rails-csrf-protection-angular-js-protect-from-forgery-makes-me-to-log-out-on
  # I don't fully know the reason why yet, but these rescues where preventing the X_XSRF_TOKEN to be verified.  This is an issue when people are trying purchase a class, only on firefox.  The errors you typically see is 'no enrollments for nil class' because it doesn't think the user is signed in.
  # Getting rid of the rescues totally alleviates those issues and moving them here helped.  If someone with deeper knowledge of this can figure this out for certain, that would be great.

  # # if Rails.env.production?
  #  # unless Rails.application.config.consider_all_requests_local
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownController, with: :render_404
  rescue_from AbstractController::ActionNotFound, with: :render_404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  #   #end
  # # end


  def render_404(exception = nil)
    @not_found_path = exception.message if exception
    logger.info('---------- render_404')
    logger.info(exception.inspect) if exception
    respond_to do |format|
      format.html { render template: 'errors/not_found', layout: 'layouts/application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
  end
end
