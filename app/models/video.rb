class Video < ActiveRecord::Base
  attr_accessible :featured, :filmstrip, :youtube_id, :title, :description

  scope :featured, where(featured:true)
  scope :filmstrip, where(filmstrip:true)

  validates :youtube_id, presence:true

  def self.featured_random
    featured.sample(1).first
  end

  def self.filmstrip_videos
    [Video.featured_random] + filmstrip.sample(4)
  end
end
