class PublishingSchedule < ActiveRecord::Base
  belongs_to :activity
  attr_accessible :activity, :publish_at
end
