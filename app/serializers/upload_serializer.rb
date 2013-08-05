class UploadSerializer < ActiveModel::Serializer
  attributes :id, :title, :notes, :image_id
  has_one :user
end
