Fixnum.class_eval do
  def hours_to_pretty_time
    case
    when self >= 8736
      years = self.hours/1.year
      # ActionController::Base.helpers.pluralize(years, "year")
      "#{years} year"
    when self >= 720
      months = self.hours/1.month
      # ActionController::Base.helpers.pluralize(months, "month")
      "#{month} month"
    when self >= 168
      weeks = self.hours/1.week
      # ActionController::Base.helpers.pluralize(weeks, "week")
      "#{weeks} week"
    when self >= 24
      days = self.hours/1.day
      # ActionController::Base.helpers.pluralize(days, "day")
      "#{days} day"
    else
      hours = self
      # ActionController::Base.helpers.pluralize(hours, "hour")
      "#{hours} hour"
    end
  end
end

Integer.class_eval do
  def hours_to_pretty_time
    self.to_i.hours_to_pretty_time
  end
end

String.class_eval do
  def hours_to_pretty_time
    self.to_i.hours_to_pretty_time
  end
end