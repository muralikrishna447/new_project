class PollItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :votes_count
  has_one :poll
end
