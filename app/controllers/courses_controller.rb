class CoursesController < ApplicationController
  include AggressiveCaching
  expose(:activities) { Activity.ordered.published.all }
  expose(:syllabus_copy) { Copy.find_by_location('course-syllabus') }
  expose(:course_description) { Copy.find_by_location('course-description') }
  expose(:bio_chris) { Copy.find_by_location('instructor-chris') }
  expose(:bio_grant) { Copy.find_by_location('instructor-grant') }
end

