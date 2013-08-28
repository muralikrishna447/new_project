class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :created_at, :youtube_id, :difficulty, :yield, :timing, :description, :published, :slug, :image_id, :featured_image_id, :activity_type, :last_edited_by_id, :source_activity_id, :source_type, :published_at, :author_notes, :likes_count, :currently_editing_user, :include_in_gallery, :creator, :featured_image, :like_users, :path

  def featured_image
    object.featured_image
  end

  def like_users
    object.likes.map(&:user)
  end

  def path
    activity_path(object)
  end
end
