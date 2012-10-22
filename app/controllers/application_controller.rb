class ApplicationController < ActionController::Base
  protect_from_forgery

  def global_navigation
    response.headers.add_header('Access-Controler-Allow-Origin: http://chefstepsblog.com')
    render partial: 'layouts/header'
  end
end

