class Page < ActiveRecord::Base
  extend FriendlyId
  attr_accessible :title, :content

  friendly_id :title, use: [:slugged, :history]

  validates :title, presence: true
  validates :content, presence: true

  has_many :likes, as: :likeable, dependent: :destroy
end
