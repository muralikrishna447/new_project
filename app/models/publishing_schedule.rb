class PublishingSchedule < ActiveRecord::Base
  belongs_to :activity
  attr_accessible :publish_at
  just_define_datetime_picker :publish_at, add_to_attr_accessible: true
end
