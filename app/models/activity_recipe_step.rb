class ActivityRecipeStep < ActiveRecord::Base
  include RankedModel
  ranks :step_order, with_same: :activity_id

  belongs_to :activity, touch: true, inverse_of: :recipe_steps
  belongs_to :step, touch: true, inverse_of: :activity_recipe_steps

  has_one :recipe, through: :step

  attr_accessible :activity_id, :step_id, :step_order_position

  delegate :title, :youtube_id, :directions, :image_id, :ingredient_ids, to: :step

  scope :ordered, rank(:step_order)

  def sorting_title
    "#{recipe.title} - #{title}"
  end
end

