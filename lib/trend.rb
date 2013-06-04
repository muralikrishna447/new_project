module Trend

  extend ActiveSupport::Concern

  # add your instance methods here

  # add your static(class) methods here
  module ClassMethods
    def trend_by_day(attribute = :created_at)
      # select("date(#{attribute}) as date, count(id) as stat").order('date ASC').group("date(#{attribute})").map{|a| {date: a.date, stat: a.stat.to_i}}
      data = select("date(#{attribute}) as date, count(id) as stat").order('date ASC').group("date(#{attribute})")
      daterange = (startdate..Date.today)
      results = []
      daterange.each do |date|
        data_point = data.select{|a| a.date.to_date == date}.first
        stat = data_point ? data_point.stat.to_i : 0
        results << [date, stat]
      end
      return results
    end

    def max_by_day
      trend_by_day.max_by{|a| a[1]}
    end

    def startdate(attribute = :created_at)
      order("#{attribute} asc").first.created_at.to_date
    end
  end
end

ActiveRecord::Base.send(:include, Trend)