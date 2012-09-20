class Ingredient < ActiveRecord::Base
  has_many :recipes
  has_many :step_ingredients
  has_many :steps, through: :step_ingredients

  attr_accessible :title, :product_url, as: :admin
end

