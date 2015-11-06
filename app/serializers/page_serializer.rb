class PageSerializer < ApplicationSerializer
  attributes :id, :title, :content, :featured_image, :likes_count, :like_users, :path, :published

  def featured_image
    object.featured_image
  end

  def like_users
    object.likes.map(&:user)
  end

  def path
    if object.primary_path
      object.primary_path
    else
      page_path(object)
    end
  end
end
