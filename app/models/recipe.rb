class Recipe < ActiveRecord::Base
  belongs_to :activity, inverse_of: :recipes, touch: true
  has_many :ingredients, class_name: RecipeIngredient, inverse_of: :recipe
  has_many :steps, dependent: :destroy, inverse_of: :recipe

  attr_accessible :title, :activity_id, :yield,
    :ingredients_attributes, :step_ids,
    allow_destroy: true, as: :admin
  accepts_nested_attributes_for :ingredients, allow_destroy: true
end

