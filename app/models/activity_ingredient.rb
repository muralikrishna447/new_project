class ActivityIngredient < ApplicationRecord
  self.primary_key = 'id'
  include Quantity

  belongs_to :activity, touch: true, inverse_of: :ingredients
  belongs_to :ingredient, inverse_of: :activity_ingredients

  delegate :title, :for_sale, :for_sale?, :product_url, :product_url?, :sub_activity_id, to: :ingredient

  validates :ingredient, presence: true
  validates :activity, presence: true

  # Bad idea b/c you may want the same ingredient in the master list with two different notes.
  #validates_uniqueness_of :ingredient_id, scope: :activity_id, message: "may only be used once in a recipe. If you need to use an ingredient in more than one step, include the total amount in the master ingredient list, then split it up in the step ingredient lists."

  scope :ordered, -> { order(:ingredient_order) }

  default_scope { ordered }
end

