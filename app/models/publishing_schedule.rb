class PublishingSchedule < ActiveRecord::Base
  belongs_to :activity
  attr_accessible :publish_at
  just_define_datetime_picker :publish_at, add_to_attr_accessible: true

  # Can't use normal rails validation because this needs to happen after just_define_datetime_picker
  # copies its fields to the real publish_at. There is probably a better way.
  before_save :validate_future
  def validate_future
    raise "Date must be in future" if self.publish_at < DateTime.now
  end
end
