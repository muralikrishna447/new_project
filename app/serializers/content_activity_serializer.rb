class ContentActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :description, :url, :context

  def image
    filepicker_arbitrary_image(object.featured_image, 400)
  end

  def url
    activity_url(object)
  end

  def context
    assembly = object.containing_course
    if assembly
      if assembly.assembly_type == 'Course'
        type_name = 'Class'
      else
        type_name = assembly.assembly_type
      end
      "#{assembly.title} #{type_name}" 
    end
  end
end
