class VoteSerializer < ActiveModel::Serializer
  attributes :id

  has_one :user
  has_one :votable
end
