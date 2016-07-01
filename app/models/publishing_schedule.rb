class PublishingSchedule < ActiveRecord::Base
  belongs_to :activity
  attr_accessible :publish_at, :publish_at_pacific


  #just_define_datetime_picker :publish_at, add_to_attr_accessible: true

  # Can't use normal rails validation because this needs to happen after just_define_datetime_picker
  # copies its fields to the real publish_at. There is probably a better way.
  before_save :validate_future
  def validate_future
    raise "Date must be in future" if self.publish_at < DateTime.now
  end

  # Convert rails DateTime to the limited ISO-8601 expected by browser, in Pacific time
  # https://www.w3.org/TR/html-markup/input.datetime-local.html
  # Example: 1996-12-19T16:39:57 - at least in Chrome it will not work with the -7:00 zone part.
  def publish_at_pacific
    pst = self.publish_at.in_time_zone(Rails.application.config.chefsteps_timezone).iso8601()
    puts "PST out: #{pst}"
    pst.gsub(/:\d\d[-+]\d\d:\d\d$/, '')
  end

  def publish_at_pacific=(pst)
    # Wanted to use Rails.application.config.chefsteps_timezone.formatted_offset but it
    # doesn't account for daylight savings so doesn't roundtrip with #publish_at_pacific
    offset = Time.now.in_time_zone(Rails.application.config.chefsteps_timezone).utc_offset
    hours = offset / 3600
    pst = pst + format("%02d:00", hours)
    puts "PST in: #{pst}"
    self.publish_at = DateTime.parse(pst)
  end
end
