class ApplicationController < ActionController::Base
  protect_from_forgery
  # after_filter :set_access_control_headers, only: :global_navigation

  def global_navigation
    render partial: 'layouts/header'
  end

  # def set_access_control_headers
  #   headers['Access-Control-Allow-Origin'] = 'http://chefstepsblog.com, *'
  #   headers['Access-Control-Request-Method'] = 'GET'
  # end

  # def options
  #   render :nothing => true, :status => 204
  #   response.headers['Access-Control-Allow-Origin'] = '*'
  #   response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
  #   response.headers['Access-Control-Allow-Credentials'] = 'true'
  #   response.headers['Access-Control-Max-Age'] = '86400' # 24 hours
  #   response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept'
  # end
end

