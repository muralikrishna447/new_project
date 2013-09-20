class AssemblySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :image_id, :youtube_id, :likes_count, :comments_count, :price

  has_many :assembly_inclusions

end
