task :delete_activity_show_events => :environment do
  Event.joins("INNER JOIN activities ON activities.id = events.trackable_id").where(trackable_type: 'Activity').where(action: 'show').find_each do |event|
    
    puts "Event to be deleted: "
    puts event.inspect
    event.delete
    puts "**********************"
  end
end