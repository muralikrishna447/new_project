class ApplicationController < ActionController::Base
  include StatusHelpers
  protect_from_forgery

  if Rails.env.angular?
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

  expose(:version) { Version.current }
  expose(:current_user_presenter) { current_user.present? ? UserPresenter.new(current_user) : nil }

  def global_navigation
    render partial: 'layouts/header', :locals => { :external => true }
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
    JSON.parse(cookies["mp_#{mixpanel.instance_variable_get('@token')}_mixpanel"])['distinct_id']
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

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
  end

end

