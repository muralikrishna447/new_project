class VoteSerializer < ApplicationSerializer
  attributes :id

  has_one :user
  has_one :votable
end
