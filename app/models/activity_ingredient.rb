class ActivityIngredient < ActiveRecord::Base
  belongs_to :activity
  belongs_to :ingredient

  attr_accessible :activity_id, :ingredient_id, :quantity, as: :admin

  delegate :title, to: :ingredient
end

