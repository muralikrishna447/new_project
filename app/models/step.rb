class Step < ActiveRecord::Base
  belongs_to :activity

  def has_video?
    video_url.to_s != ''
  end
end
