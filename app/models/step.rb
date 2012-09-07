class Step < ActiveRecord::Base
  belongs_to :activity, touch: true

  attr_accessible :title, :video_url, :activity_id, as: :admin

  def video?
    video_url.present?
  end
end
