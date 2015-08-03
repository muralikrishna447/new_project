class Page < ActiveRecord::Base
  extend FriendlyId
  attr_accessible :title, :content, :image_id, :primary_path, :short_description

  friendly_id :title, use: [:slugged, :history]

  validates :title, presence: true
  validates :content, presence: true

  has_many :likes, as: :likeable, dependent: :destroy

  def featured_image
    image_id
  end
end
