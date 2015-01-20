class ContentUploadSerializer < ApplicationSerializer
  attributes :id, :title, :image, :description, :url, :context

  def image
    filepicker_arbitrary_image(object.featured_image, 400)
  end

  def description
    object.notes
  end

  def url
    upload_url(object)
  end

  def context
    object.uploadable.title
  end
end