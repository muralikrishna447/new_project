class CirculatorUser < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :circulator
  belongs_to :user

  attr_accessible :owner, :user, :circulator

  after_commit :user_sync
  after_destroy :user_sync

  def user_sync
    Resque.enqueue(UserSync, self.user.id)
  end

  def self.find_by_circulator_and_user(circulator, user)
    CirculatorUser.where(circulator_id: circulator.id, user_id: user).first
  end
end
