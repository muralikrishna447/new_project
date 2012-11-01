class ActivityRecipe < ActiveRecord::Base
  include RankedModel
  ranks :recipe_order, with_same: :activity_id

  belongs_to :activity, touch: true, inverse_of: :recipes
  belongs_to :recipe, inverse_of: :activity_recipes

  validates :activity_id, presence: true
  validates :recipe_id, presence: true
  attr_accessible :activity_id, :recipe_id, :recipe, :recipe_order_position

  delegate :title, :ingredients, :steps, :has_ingredients?, to: :recipe

  scope :ordered, rank(:recipe_order)
end

