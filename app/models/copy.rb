class Copy < ActiveRecord::Base
  attr_accessible :location, :copy, as: :admin

  # used by active admin for display
  def title
    location
  end

  def to_s
    copy
  end
end
