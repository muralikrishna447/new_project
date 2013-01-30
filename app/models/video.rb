class Video < ActiveRecord::Base
  attr_accessible :featured, :filmstrip, :youtube_id, :title, :description, :image_id

  scope :featured, where(featured:true)
  scope :filmstrip, where(filmstrip:true)

  validates :youtube_id, presence:true
  validates :title, presence:true

  def self.featured_random
    featured.sample(1).first
  end

  def self.filmstrip_videos
    featured_video = Video.featured_random
    if filmstrip.any?
      filmstrip.sample(5)
    else
      Activity.new_content
    end
  end

  def self.featured_id
    Video.featured.any? ? Video.featured.first.youtube_id : '9lWGCR0RSn4'
  end

end
