class AssemblySerializer < ApplicationSerializer
  attributes :id, :title, :description, :image_id, :youtube_id, :vimeo_id, :likes_count, :comments_count, :price, :featured_image, :assembly_type, :path, :upload_copy, :badge_image, :published_at

  has_many :assembly_inclusions

  def featured_image
    object.image_id
  end

  def path
    landing_assembly_path(object)
  end

  def badge_image
    object.badge ? object.badge.image : nil
  end

end
