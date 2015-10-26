class ChefstepsMixpanel < Mixpanel::Tracker

  def initialize
    if Rails.env.production?
      super('84272cf32ff65b70b86639dacd53c0e0')
    else
      super('d6d82f805f7d8a138228a52f17d6aaec')
    end
  end

  def track(distinct_id, event, properties={}, ip=nil)
    super
  rescue StandardError
    puts "An error occured with mixpanel.track"
  end

  def alias(alias_id, real_id, events_endpoint=nil)
    super
  rescue StandardError
    puts "An error occured with mixpanel.alias"
  end

end