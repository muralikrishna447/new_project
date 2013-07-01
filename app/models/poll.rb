class Poll < ActiveRecord::Base
  attr_accessible :description, :slug, :status, :title, :poll_items_attributes
  has_many :poll_items

  accepts_nested_attributes_for :poll_items
end
