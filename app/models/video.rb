class Video < ActiveRecord::Base
  attr_accessible :featured, :filmstrip, :youtube_id, :title, :description

  scope :featured, where(featured:true)
  scope :filmstrip, where(filmstrip:true)

  def self.featured_random
    featured.sample(1).first.youtube_id
  end
end
