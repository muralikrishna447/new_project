class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :created_at, :commentable_type, :rating
  has_one :user
  has_one :commentable
end
