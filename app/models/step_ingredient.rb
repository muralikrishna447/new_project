class StepIngredient < ActiveRecord::Base
  include RankedModel
  include Quantity
  ranks :ingredient_order, with_same: :step_id

  belongs_to :step, inverse_of: :ingredients
  belongs_to :ingredient, inverse_of: :step_ingredients

  delegate :title, :for_sale, :for_sale?, :product_url, :product_url?, :sub_activity_id, to: :ingredient

  attr_accessible :step_id, :ingredient_id, :quantity, :unit, :ingredient_order_position

  validates :ingredient_id, presence: true
  validates :step_id, presence: true

  scope :ordered, rank(:ingredient_order)

  default_scope { ordered }
end

