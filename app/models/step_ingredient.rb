class StepIngredient < ActiveRecord::Base
  include RankedModel
  ranks :ingredient_order, with_same: :step_id

  belongs_to :step, inverse_of: :ingredients
  belongs_to :ingredient, inverse_of: :step_ingredients

  attr_accessible :step_id, :ingredient_id, :quantity, :unit, as: :admin

  delegate :title, to: :ingredient

  scope :ordered, rank(:ingredient_order)

  default_scope { ordered }

  def label
    [title, [quantity, unit].compact.join].compact.join(" ")
  end
end

