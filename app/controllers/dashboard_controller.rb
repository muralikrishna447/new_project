class DashboardController < ApplicationController
  before_filter :require_admin

  def index
    @user_signups = User.order('created_at ASC').map(&:created_at).group_by(&:end_of_day).map{|k,v| [k.to_date, v.count]}
  end

private

  def require_admin
    unless admin_user_signed_in?
      flash[:error] = "You must be logged in as an administrator to do this"
      redirect_to new_admin_user_session_path
    end
  end

end