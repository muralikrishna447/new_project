class CoursesController < ApplicationController

  expose(:activities) { Activity.ordered.published.all }
  expose(:activity) { Activity.find_published(params[:id], params[:token])}
  expose(:course) { Course.find(params[:id]) }
  expose(:bio_chris) { Copy.find_by_location('instructor-chris') }
  expose(:bio_grant) { Copy.find_by_location('instructor-grant') }

  def show
    @course = Course.find(params[:id])
    if @course.title == 'Spherification'
      render 'spherification'
    end
  end
end

