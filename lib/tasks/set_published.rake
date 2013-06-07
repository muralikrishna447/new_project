task :set_published => :environment do
  activities = Activity.published
  activities.each do |activity|
    activity.published_at = activity.created_at
    if activity.save
      puts "Set published_at date for: #{activity.inspect}"
    end
  end
end