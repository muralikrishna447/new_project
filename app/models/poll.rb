class Poll < ActiveRecord::Base
  attr_accessible :description, :slug, :status, :title
  has_many :poll_items
end
