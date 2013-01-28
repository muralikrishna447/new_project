class Video < ActiveRecord::Base
  attr_accessible :featured, :filmstrip, :youtube_id, :title, :description

  scope :featured, where(featured:true)
  scope :filmstrip, where(filmstrip:true)

  validates :youtube_id, presence:true

  def self.featured_random
    featured.sample(1).first
  end

  def self.filmstrip_videos
    featured_video = Video.featured_random
    if featured_video && filmstrip.any?
      [featured_video] + filmstrip.sample(4)
    elsif featured_video && filmstrip.blank?
      [featured_video] + Activity.new_content.limit(4)
    else
      Activity.new_content
    end
  end

end
