# http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution

class ErrorsController < ApplicationController
  def routing
    render_404
  end
end