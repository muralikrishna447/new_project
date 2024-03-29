class UploadSerializer < ApplicationSerializer
  attributes :id, :title, :notes, :featured_image, :likes_count, :like_users, :path, :approved
  has_one :user
  has_one :activity
  has_one :assembly

  def featured_image
    object.featured_image
  end

  def like_users
    object.likes.map(&:user)
  end

  def path
    upload_path(object)
  end
end
