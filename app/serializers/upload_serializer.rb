class UploadSerializer < ActiveModel::Serializer
  attributes :id, :title, :notes, :featured_image, :likes_count, :like_users
  has_one :user

  def featured_image
    object.featured_image
  end

  def like_users
    object.likes.map(&:user)
  end

end
