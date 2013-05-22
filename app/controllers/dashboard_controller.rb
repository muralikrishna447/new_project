class DashboardController < ApplicationController
  before_filter :require_admin

  def index
    # @user_signups = User.order('created_at ASC').map(&:created_at).group_by(&:end_of_day).map{|k,v| [k.to_date, v.count]}
    @users_count = User.count
    @users_ten_views_count = User.joins(:events).select('events.user_id').group('events.user_id').having('count(events.id) >=10').count
    @enrollments_count = Enrollment.count
    @uploads_count = User.joins(:uploads).select('uploads.user_id').group('uploads.user_id').count
  end

private

  def require_admin
    unless admin_user_signed_in?
      flash[:error] = "You must be logged in as an administrator to do this"
      redirect_to new_admin_user_session_path
    end
  end

end