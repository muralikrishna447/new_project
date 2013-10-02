class CoursesController < ApplicationController
  before_filter :authenticate_user!, only: [:enroll]
  expose(:activities) { Activity.ordered.published.all }
  expose(:activity) { Activity.find_published(params[:id], params[:token])}
  expose(:course) { Course.find(params[:id]) }
  expose(:bio_chris) { Copy.find_by_location('instructor-chris') }
  expose(:bio_grant) { Copy.find_by_location('instructor-grant') }

  def index
    @courses = Course.published.order('updated_at desc').page(params[:page]).per(12)
  end

  def show
    @course = Course.find_published(params[:id], params[:token], can?(:update, @activity))
    if @course.title == 'Spherification'
      @new_user = User.new
      render 'spherification'
    elsif @course.title == 'Science of Poutine'
      @new_user = User.new
      render 'poutine'
    elsif @course.title == 'Knife Sharpening'
      @new_user = User.new
      render 'knife-sharpening'
      finished('knife ads', :reset => false)
      finished('knife ads large', :reset => false)      
    end

  end

  def enroll
    @course = Course.find(params[:id])
    @enrollment = Enrollment.new(user_id: current_user.id, enrollable: @course)
    if @enrollment.save
      redirect_to course_path(@course), notice: "You are now enrolled!"
      track_event @course
      finished('poutine', :reset => false)
      finished('free or not', :reset => false)
    end
  end

end

