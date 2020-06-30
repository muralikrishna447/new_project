# http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution

class ErrorsController < ApplicationController
  skip_before_action :set_analytics_cookie
  def routing
    render_404
  end
end
