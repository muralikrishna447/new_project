class ApplicationController < ActionController::Base
  protect_from_forgery

  def global_navigation
    render partial: 'layouts/header', locals: {show_auth: false}
  end

end

