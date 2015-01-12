class CoursesController < ApplicationController
  before_filter :handle_ambassador, only: [:show, :index]
  def handle_ambassador
    if params[:ambassador]
      # 25% off
      session[:coupon] = 'a1b71d389a50'
      session[:ambassador] = params[:ambassador]
      flash.now[:notice] = "Welcome! You will receive a 25% discount on any paid class."
      mixpanel.track(mixpanel_anonymous_id, 'Ambassador Landing Viewed', {ambassador: params[:ambassador]})
    end
  end

  def index
    @pubbed_courses = Assembly.pubbed_courses.order('created_at desc')
    @prereg_courses = Assembly.prereg_courses.order('created_at desc')
    @assembly_courses = @pubbed_courses | @prereg_courses
  end
end

