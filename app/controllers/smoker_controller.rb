class SmokerController < ApplicationController
  before_filter :only_admin
  def only_admin 
    redirect_to "/" unless (current_user && current_user.admin?)
  end

  def index
  end
end
