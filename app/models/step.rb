class Step < ActiveRecord::Base
  include RankedModel
  ranks :step_order, with_same: :recipe_id

  belongs_to :activity, touch: true
  belongs_to :recipe, touch: true, inverse_of: :steps

  has_many :ingredients, class_name: StepIngredient, inverse_of: :step

  attr_accessible :title, :youtube_id, :recipe_id, :directions, :image_id,
    :ingredient_ids, :activity_id, as: :admin

  scope :ordered, rank(:step_order)

  default_scope { ordered }
end

