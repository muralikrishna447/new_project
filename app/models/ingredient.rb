class Ingredient < ActiveRecord::Base
  has_many :activity_ingredients
  has_many :recipes, through: :activity_ingredients

  attr_accessible :title, :product_url, as: :admin
end

