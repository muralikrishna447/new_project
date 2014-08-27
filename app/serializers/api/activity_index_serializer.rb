class Api::ActivityIndexSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :image, :url, :likesCount

  def image
    filepicker_to_s3_url(object.featured_image_id)
  end

  def url
    activity_url(object)
  end

  def likesCount
    object.likes_count
  end
end
