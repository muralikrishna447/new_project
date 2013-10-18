class CourseSerializer < ActiveModel::Serializer
  attributes :id, :title, :featured_image, :path
  
  def path
    course_path(object)
  end
end
