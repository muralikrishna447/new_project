class Copy < ActiveRecord::Base
  attr_accessible :location, :markdown, as: :admin
end
