class CoursesController < ApplicationController
  before_filter :authenticate_user!, only: [:enroll]
  expose(:activities) { Activity.ordered.published.all }
  expose(:activity) { Activity.find_published(params[:id], params[:token])}
  expose(:course) { Course.find(params[:id]) }
  expose(:bio_chris) { Copy.find_by_location('instructor-chris') }
  expose(:bio_grant) { Copy.find_by_location('instructor-grant') }

  def index
    @courses = Course.published.page(params[:page]).per(12)
  end

  def show
    @course = Course.find(params[:id])
    if @course.title == 'Spherification'
      # @frozen_reverse_spheres = Activity.find([259,311])
      # @beet_spheres = Activity.find([239])
      # @easier_direct_spheres = Activity.find([309])
      # @low_ph_spheres = Activity.find([299])
      # @quiz = Activity.find([301])
      # @final = Activity.find([260])
      # @badge = Activity.find([302])
      # @creative = @course.viewable_activities - @frozen_reverse_spheres - @beet_spheres - @easier_direct_spheres - @low_ph_spheres - @quiz - @final - @badge
      # @enthusiast = @course.viewable_activities - @easier_direct_spheres - @low_ph_spheres - @quiz - @final - @badge
      # @professional = @course.viewable_activities - @quiz - @final - @badge
      @new_user = User.new
      render 'spherification'
    end
  end

  def enroll
    @course = Course.find(params[:id])
    @enrollment = Enrollment.new(user_id: current_user.id, course_id: @course.id)
    if @enrollment.save
      redirect_to course_path(@course), notice: "You are now enrolled!"
      track_event @course
    end
  end

end

