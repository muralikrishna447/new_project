task :engagement_report => :environment do
  users = User.order('created_at DESC')
  puts '"id", "name", "email", "days signed up", "paid enrollment", "total events", "events per day", "days with an event"'
  users.each do |u|
    days_signed_up = (DateTime.now - u.created_at.to_datetime).to_i
    paid_enrollment = Enrollment.where(user_id: u.id).first
    paid_enrollment = paid_enrollment ? (paid_enrollment.price > 0) : false
    events = Event.where(user_id: u.id).order('created_at ASC')
    days_with_an_event = {}
    events.each do |e| 
      days_with_an_event[e.created_at.to_date] = true
    end
    puts "#{u.id}, #{u.name}, #{u.email}, #{days_signed_up}, #{paid_enrollment}, #{events.count}, #{(events.count.to_f / days_signed_up).round(1)}, #{days_with_an_event.count}"
  end
end