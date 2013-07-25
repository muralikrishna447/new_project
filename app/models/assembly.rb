class Assembly < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  attr_accessible :description, :image_id, :title, :youtube_id, :slug, :assembly_type, :assembly_inclusions_attributes
  has_many :assembly_inclusions
  has_many :includables, through: :assembly_inclusions

  accepts_nested_attributes_for :assembly_inclusions, allow_destroy: true

  ASSEMBLY_TYPE_SELECTION = ['Project']
  INCLUDABLE_TYPE_SELECTION = ['Activity']

  def ingredients
    assembly_inclusions.map(&:includable).map(&:ingredients).flatten.sort_by{|i|i.ingredient.title}.reject{|i| i.unit == 'recipe'}
  end

  def grouped_ingredients
    self.ingredients.group_by{|assembly_ingredient| [assembly_ingredient.ingredient, assembly_ingredient.note, assembly_ingredient.unit]}
  end

  def combined_ingredients
    self.grouped_ingredients.map{ |ingredient_group| [ingredient_group[0], ingredient_group[1].map(&:quantity).inject(:+), ingredient_group[1][0].unit] }
  end

  def equipment
    assembly_inclusions.map(&:includable).map(&:terminal_equipment).flatten.uniq.sort_by{ |e| e.title }
  end
end
