class CoursesController < ApplicationController
  before_filter :handle_ambassador, only: [:show, :index]
  def handle_ambassador
    if params[:ambassador]
      session[:ambassador] = params[:ambassador]
      mixpanel.track(mixpanel_anonymous_id, 'Ambassador Landing Viewed', {ambassador: params[:ambassador]})

      # 25% off
      session[:coupon] = 'a1b71d389a50'
      # Note: this hasn't worked for awhile apparently, but we also no longer user the ambassador program, this crap can all go away
      flash.now[:notice] = "Welcome! You will receive a 25% discount on any paid class."
    end
  end

  def index
    @pubbed_courses = Assembly.pubbed_courses.order('created_at desc')
    @prereg_courses = Assembly.prereg_courses.order('created_at desc')
    @assembly_courses = @pubbed_courses | @prereg_courses
  end
end

