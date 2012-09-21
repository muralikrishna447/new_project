class RecipeIngredient < ActiveRecord::Base
  include RankedModel
  ranks :ingredient_order, with_same: :recipe_id

  belongs_to :recipe, touch: true, inverse_of: :ingredients
  belongs_to :ingredient, inverse_of: :recipe_ingredients

  delegate :title, to: :ingredient

  validates :ingredient, presence: true
  validates :recipe, presence: true

  attr_accessible :recipe_id, :ingredient_id, :quantity, :unit, as: :admin

  scope :ordered, rank(:ingredient_order)

  default_scope { ordered }

  def label
    [title, [quantity, unit].compact.join].compact.join(" ")
  end
end

