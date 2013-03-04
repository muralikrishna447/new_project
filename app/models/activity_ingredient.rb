class ActivityIngredient < ActiveRecord::Base
  include RankedModel
  include Quantity

  ranks :ingredient_order, with_same: :activity_id

  belongs_to :activity, touch: true, inverse_of: :ingredients
  belongs_to :ingredient, inverse_of: :activity_ingredients

  delegate :title, :for_sale, :for_sale?, :product_url, :product_url?, :sub_activity_id, to: :ingredient

  validates :ingredient, presence: true
  validates :activity, presence: true

  attr_accessible :activity_id, :ingredient_id, :quantity, :unit, :ingredient_order_position

  scope :ordered, rank(:ingredient_order)

  default_scope { ordered }
end

