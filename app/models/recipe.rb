class Recipe < ActiveRecord::Base
  belongs_to :activity, touch: true
  has_many :ingredients, class_name: RecipeIngredient
  has_many :steps, dependent: :destroy

  attr_accessible :title, :activity_id, as: :admin

end

