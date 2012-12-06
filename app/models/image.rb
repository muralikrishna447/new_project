class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true

  attr_accessible :filename, :url, :caption, :imageable_id
end

