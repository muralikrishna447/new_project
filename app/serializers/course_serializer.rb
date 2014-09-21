class CourseSerializer < ApplicationSerializer
  attributes :id, :title, :featured_image, :path
  
  def path
    course_path(object)
  end
end
