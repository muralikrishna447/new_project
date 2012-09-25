class CoursesController < ApplicationController
  include AggressiveCaching
  expose(:activities) { Activity.all }
  expose(:syllabus_copy) { Copy.find_by_location('course-syllabus') }
  expose(:course_description) { Copy.find_by_location('course-description') }
end

