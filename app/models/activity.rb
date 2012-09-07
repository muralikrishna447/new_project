class Activity < ActiveRecord::Base
  has_many :steps, :dependent => :destroy

  def has_video?
    video_url.to_s != ''
  end
end
