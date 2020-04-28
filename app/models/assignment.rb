class Assignment < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  belongs_to :activity
  belongs_to :child_activity, class_name: 'Activity'
end
