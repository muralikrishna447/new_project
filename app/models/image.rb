class Image < ActiveRecord::Base
  include UpdateWhitelistAttributes

  belongs_to :imageable, polymorphic: true

  attr_accessible :filename, :url, :caption, :imageable_id
end

