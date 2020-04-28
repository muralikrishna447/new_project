class StepIngredient < ActiveRecord::Base
  include Quantity

  belongs_to :step, inverse_of: :ingredients
  belongs_to :ingredient, inverse_of: :step_ingredients

  delegate :title, :for_sale, :for_sale?, :product_url, :product_url?, :sub_activity_id, to: :ingredient

  validates :ingredient_id, presence: true
  validates :step_id, presence: true
  validates_uniqueness_of :ingredient_id, scope: :step_id, message: "may only be used once in a step. Consider splitting up the step."

  scope :ordered, -> { order(:ingredient_order) }

  default_scope { ordered }
end

