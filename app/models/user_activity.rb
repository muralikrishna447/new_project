class UserActivity < ActiveRecord::Base
  attr_accessible :action, :activity_id, :user_id
end
