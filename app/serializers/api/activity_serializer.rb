class Api::ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :image, :url, :likes_count

  def image
    object.featured_image_id
  end

  def url
    activity_url(object)
  end
end
