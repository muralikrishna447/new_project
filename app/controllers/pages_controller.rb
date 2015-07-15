class PagesController < ApplicationController

  def show
    @page = Page.find(params[:id])
    respond_to do |format|
      format.html
      format.json do
        render json: @page.content
      end
    end
  end

  def password_reset_sent
    render 'devise/passwords/reset_sent'
  end

  def knife_collection
    # @knife_page = Page.find 'knife-collection'
  end

  def sv_collection
    @sv_page = Page.find 'sous-vide-collection'
  end

  def sous_vide_jobs
    @page = Page.find 'sous-vide-jobs'
  end

  def egg_timer
    if Rails.env.production?
      authenticate_or_request_with_http_basic('Tools') do |username, password|
        username == 'delve' && password == 'howtoegg22'
      end
    end
    Page.find 'egg-timer'
  end

  def test_purchaseable_course
    @page = Page.find 'test-purchaseable-course'
    @assembly = Assembly.find('test-purchaseable-course')
    @enrolled = current_user ? Enrollment.where(user_id: current_user.id, enrollable_id: @assembly.id, enrollable_type: 'Assembly').first : false
  end

  def mobile_about
    @mobile_about = Page.find 'mobile-about'
    render layout: false
  end
end
