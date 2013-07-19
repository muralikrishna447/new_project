class Followership < ActiveRecord::Base
  attr_accessible :follower_id, :user_id
  belongs_to :user
  belongs_to :follower, class_name: 'User'

  validates_uniqueness_of :user_id, :scope => :follower_id
end
