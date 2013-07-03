class PollItem < ActiveRecord::Base
  attr_accessible :description, :poll_id, :status, :title

  belongs_to :poll

  has_many :votes, as: :votable
  has_many :users, through: :votes
end
