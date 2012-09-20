class RecipeIngredient < ActiveRecord::Base
  belongs_to :recipe, touch: true, inverse_of: :ingredients
  belongs_to :ingredient, inverse_of: :recipe_ingredients

  attr_accessible :recipe_id, :ingredient_id, :quantity, :unit, as: :admin

  delegate :title, to: :ingredient
end

