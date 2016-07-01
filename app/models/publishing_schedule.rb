class PublishingSchedule < ActiveRecord::Base
  belongs_to :activity
  attr_accessible :publish_at, :publish_at_pacific

  validates :publish_at, inclusion: { in: (DateTime.now..DateTime.now+1000.years),  message: "must be in future" }

  # :publish_at is the actual database field; this pair of setters/getters for publish_at_pacific
  # is used by the form to present the form in a way that makes the browser happy.

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
