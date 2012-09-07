class Activity < ActiveRecord::Base

  def has_video?
    !video_url.nil?
  end
end
