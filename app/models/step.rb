class Step < ActiveRecord::Base
  include RankedModel
  include VideoHelper
  ranks :step_order

  belongs_to :activity, touch: true

  attr_accessible :title, :youtube_id, :activity_id, as: :admin

  scope :ordered, rank(:step_order)

  def video_url
    build_video_url(youtube_id)
  end
end

