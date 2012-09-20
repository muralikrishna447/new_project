class Ingredient < ActiveRecord::Base
  has_many :step_ingredients, inverse_of: :ingredient
  has_many :recipe_ingredients, inverse_of: :ingredient
  has_many :recipes, through: :recipe_ingredients, inverse_of: :ingredients

  attr_accessible :title, :product_url, as: :admin
end

