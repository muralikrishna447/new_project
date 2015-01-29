class ChefstepsMixpanel < Mixpanel::Tracker

  def initialize(object)
    super
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