class Api::ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description
end
