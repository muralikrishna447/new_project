class ContentUploadSerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :description, :url

  def image
    filepicker_arbitrary_image(object.featured_image, 400)
  end

  def description
    object.notes
  end

  def url
    upload_url(object)
  end
end