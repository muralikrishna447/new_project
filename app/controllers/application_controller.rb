class ApplicationController < ActionController::Base
  include StatusHelpers
  protect_from_forgery

  expose(:version) { Version.current }
  expose(:current_user_presenter) { current_user.present? ? UserPresenter.new(current_user) : nil }

  def global_navigation
    render partial: 'layouts/header', :locals => { :external => true }
  end

  # expose devise helper method to views
  helper_method :after_sign_in_path_for

  # On sign in, if profile isn't complete, nudge them to finish it now
  def after_sign_in_path_for(user)
    return super(user) if user.admin? || user.profile_complete?
    super(user)
    user_profile_path(user)
  end

  def authenticate_active_admin_user!
    authenticate_user!
    unless current_user.role?(:admin)
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
    @mixpanel ||= Mixpanel::Tracker.new '84272cf32ff65b70b86639dacd53c0e0', { :env => request.env }
  end

  # See http://stackoverflow.com/questions/14734243/rails-csrf-protection-angular-js-protect-from-forgery-makes-me-to-log-out-on
  after_filter  :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X_XSRF_TOKEN']
  end

end

