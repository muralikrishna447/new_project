class RecipeIngredient < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :ingredient

  attr_accessible :recipe_id, :ingredient_id, :quantity, :unit as: :admin

  delegate :title, to: :ingredient
end

