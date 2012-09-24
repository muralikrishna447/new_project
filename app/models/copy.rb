class Copy < ActiveRecord::Base
  attr_accessible :location, :copy, as: :admin

  def to_s
    copy
  end
end
