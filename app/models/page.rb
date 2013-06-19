class Page < ActiveRecord::Base
  extend FriendlyId
  attr_accessible :title, :content

  friendly_id :title, use: [:slugged, :history]

  validates :title, presence: true
  validates :content, presence: true
end
