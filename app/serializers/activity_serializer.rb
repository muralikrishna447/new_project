class ActivitySerializer < ApplicationSerializer
  attributes :id, :title, :created_at, :youtube_id, :difficulty, :yield, :timing, :description, :published, :slug, :image_id, :featured_image_id, :activity_type, :last_edited_by_id, :source_activity_id, :source_type, :published_at, :author_notes, :likes_count, :currently_editing_user, :include_in_gallery, :creator, :featured_image, :like_users, :path, :show_only_in_course, :gallery_path

  def featured_image
    object.featured_image
  end

  def like_users
    object.likes.map(&:user)
  end

  def path
    activity_path(object)
  end

  def gallery_path
    object.gallery_path
  end
end
