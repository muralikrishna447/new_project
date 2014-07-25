class ContentActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :description, :url

  def image
    filepicker_arbitrary_image(object.featured_image, 400)
  end

  def url
    activity_url(object)
  end
end
