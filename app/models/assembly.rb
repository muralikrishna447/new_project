class Assembly < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  attr_accessible :description, :image_id, :title, :youtube_id
  has_many :assembly_inclusions

end
