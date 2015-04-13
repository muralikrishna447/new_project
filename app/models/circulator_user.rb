class CirculatorUser < ActiveRecord::Base
  belongs_to :circulator
  belongs_to :user

  attr_accessible :owner
end
