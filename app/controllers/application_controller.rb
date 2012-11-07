class ApplicationController < ActionController::Base
  protect_from_forgery

  def global_navigation
    render partial: 'layouts/header', locals: {show_auth: false}
  end

  # # expose devise helper method to views
  helper_method :after_sign_in_path_for

end

