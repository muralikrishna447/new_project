class Step < ActiveRecord::Base
  include RankedModel
  ranks :step_order

  belongs_to :activity, touch: true
  belongs_to :recipe, touch: true

  attr_accessible :title, :youtube_id, :recipe_id, :activity_id, as: :admin

  scope :ordered, rank(:step_order)
end

