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
      if request.referer && URI(request.referer).host == URI(root_url).host
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
    if Rails.env.development?
      @mixpanel ||= Mixpanel::Tracker.new 'd6d82f805f7d8a138228a52f17d6aaec', { :env => request.env }
    else
      @mixpanel ||= Mixpanel::Tracker.new '84272cf32ff65b70b86639dacd53c0e0', { :env => request.env }
    end
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

