class AssemblySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :image_id, :youtube_id, :likes_count, :comments_count, :price, :featured_image, :assembly_type, :path

  has_many :assembly_inclusions

  def featured_image
    object.image_id
  end

  def path
    landing_class_path(object)
  end

end
