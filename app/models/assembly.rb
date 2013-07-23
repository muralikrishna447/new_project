class Assembly < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  attr_accessible :description, :image_id, :title, :youtube_id
  has_many :assembly_inclusions
  has_many :includables, through: :assembly_inclusions

  def ingredients
    assembly_inclusions.map(&:includable).map(&:ingredients).flatten.sort_by{|i|i.ingredient.title}
  end
end
