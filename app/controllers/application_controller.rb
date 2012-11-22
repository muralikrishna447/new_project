class ApplicationController < ActionController::Base
  include StatusHelpers
  protect_from_forgery

  expose(:version) { Version.current }
  expose(:current_user_presenter) { current_user.present? ? UserPresenter.new(current_user) : nil }

  def global_navigation
    render partial: 'layouts/header'
  end

  # expose devise helper method to views
  helper_method :after_sign_in_path_for, :last_stored_location_for

  def stored_location_for(resource_or_scope)
    session['last_user_return_to'] = session['user_return_to'] if session['user_return_to'].present?
    super(resource_or_scope)
  end

  def last_stored_location_for(resource_or_scope)
    session.delete('last_user_return_to')
  end

  # On sign in, if profile isn't complete, nudge them to finish it now
  def after_sign_in_path_for(user)
    return super(user) if user.admin? || user.profile_complete?
    user_profile_path(user)
  end

end

