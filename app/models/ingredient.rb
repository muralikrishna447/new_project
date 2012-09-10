class Ingredient < ActiveRecord::Base
  has_many :activities, through: :activity_ingredients

  attr_accessible :title, :product_url, as: :admin
end

