class Assignment < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  attr_accessible :activity_id, :child_activity_id, :title, :description, :slug
  belongs_to :activity
  belongs_to :child_activity, class_name: 'Activity'
end
