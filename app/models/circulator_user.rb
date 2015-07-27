class CirculatorUser < ActiveRecord::Base
  belongs_to :circulator
  belongs_to :user

  attr_accessible :owner, :user, :circulator

  def self.find_by_circulator_and_user(circulator, user)
    CirculatorUser.where(circulator_id: circulator.id, user_id: user).first
  end
end
