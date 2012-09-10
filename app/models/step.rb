class Step < ActiveRecord::Base
  include RankedModel
  ranks :step_order

  belongs_to :activity, touch: true

  attr_accessible :title, :video_url, :activity_id, as: :admin

  scope :ordered, rank(:step_order)
end

