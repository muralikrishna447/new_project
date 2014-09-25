class PollItemSerializer < ApplicationSerializer
  attributes :id, :title, :description, :votes_count
  has_one :poll
end
