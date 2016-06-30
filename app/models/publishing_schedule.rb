class PublishingSchedule < ActiveRecord::Base
  belongs_to :activity
  attr_accessible :activity, :publish_at
  just_define_datetime_picker :publish_at
end
