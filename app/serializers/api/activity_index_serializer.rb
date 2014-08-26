class Api::ActivityIndexSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :image, :url, :likes_count

  def image
    filepicker_to_s3_url(object.featured_image_id)
  end

  def url
    activity_url(object)
  end
end
