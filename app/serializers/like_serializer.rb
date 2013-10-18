class LikeSerializer < ActiveModel::Serializer
  attributes :id, :likeable_type, :likeable_id
  has_one :likeable
end
