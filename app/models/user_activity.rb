class UserActivity < ActiveRecord::Base
  attr_accessible :action, :activity_id, :user_id
  belongs_to :user
  belongs_to :activity

  default_scope order('created_at DESC')
end
