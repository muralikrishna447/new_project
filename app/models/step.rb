class Step < ActiveRecord::Base
  include RankedModel
  include ApplicationHelper
  ranks :step_order

  belongs_to :activity, touch: true

  attr_accessible :title, :video_url, :activity_id, as: :admin

  scope :ordered, rank(:step_order)

  def video
    build_video_url(video_url)
  end
end

