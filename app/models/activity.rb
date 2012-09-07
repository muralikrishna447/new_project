class Activity < ActiveRecord::Base
  has_many :steps

  def has_video?
    !video_url.nil?
  end
end
