class Assignment < ActiveRecord::Base
  attr_accessible :activity_id, :child_activity_id
  belongs_to :activity
  belongs_to :child_activity, class_name: 'Activity'
end
