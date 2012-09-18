class Recipe < ActiveRecord::Base
  belongs_to :activity, touch: true
  has_many :ingredients, class_name: RecipeIngredient

  attr_accessible :title, :activity_id, as: :admin

end

