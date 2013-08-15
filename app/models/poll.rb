class Poll < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  
  attr_accessible :description, :slug, :status, :title, :image_id, :poll_items_attributes
  has_many :poll_items

  accepts_nested_attributes_for :poll_items
end
