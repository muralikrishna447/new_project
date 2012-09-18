class StepIngredient < ActiveRecord::Base
  belongs_to :step
  belongs_to :ingredient

  attr_accessible :step_id, :ingredient_id, :quantity, :unit, as: :admin

  delegate :title, to: :ingredient
end

