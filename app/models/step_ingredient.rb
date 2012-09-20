class StepIngredient < ActiveRecord::Base
  belongs_to :step, inverse_of: :ingredients
  belongs_to :ingredient, inverse_of: :step_ingredients

  attr_accessible :step_id, :ingredient_id, :quantity, :unit, as: :admin

  delegate :title, to: :ingredient
end

