class Assembly < ActiveRecord::Base
  attr_accessible :description, :image_id, :title, :youtube_id
  has_many :assembly_inclusions
end
