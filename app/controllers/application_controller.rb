class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :set_access_control_headers, only: :global_navigation

  def global_navigation
    render partial: 'layouts/header'
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'http://chefstepsblog.com'
    headers['Access-Control-Request-Method'] = 'GET'
  end
end

