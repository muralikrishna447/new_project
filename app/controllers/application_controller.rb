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
    user_profile_path(user)
  end

private
  
  def track_event(trackable, action = params[:action])
    if current_user
      current_user.events.create! action: action, trackable: trackable
    end
  end

end

