class Copy < ActiveRecord::Base
  attr_accessible :location, :copy, as: :admin
end
