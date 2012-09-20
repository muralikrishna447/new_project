class Step < ActiveRecord::Base
  include RankedModel
  ranks :step_order, with_same: :recipe_id

  belongs_to :activity, touch: true
  belongs_to :recipe, touch: true

  has_many :ingredients, class_name: StepIngredient

  attr_accessible :title, :youtube_id, :recipe_id, :activity_id, as: :admin

  scope :ordered, rank(:step_order)

  default_scope { ordered }
end

