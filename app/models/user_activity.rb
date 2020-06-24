class UserActivity < ApplicationRecord

  belongs_to :user
  belongs_to :activity

  default_scope -> { order('created_at DESC') }

  validate :time_scope

private
  def time_scope
    results = UserActivity.where("user_id = ? AND activity_id = ? AND created_at BETWEEN ? AND ?", self.user_id, self.activity_id, Time.now - 1.minute, Time.now).all
    if results.any?
      errors.add(:user_id, 'can only post once a day')
    end
  end
end
