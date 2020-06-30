class ReportsController < ApplicationController
  before_action :ensure_admin

  def index

  end

  def stripe
    if request.post?
      Resque.enqueue(ReportGenerator, "stripe", current_user.id, params[:start_date], params[:end_date])
      redirect_to reports_path, notice: "Report will be emailed to #{current_user.email} as soon as it is complete."
    end
  end


  private

  def ensure_admin
    redirect_to root_url unless current_user && current_user.role?(:admin)
  end
end