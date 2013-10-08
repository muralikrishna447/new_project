task :bestow_free_course_on_macaron_voters => :environment do
  users = Vote.where(votable_type: "PollItem", votable_id: 3).map { |v| v.user ? v.user.id : 0}.uniq
  enrollable = Assembly.find('french-macarons')
  puts "Bestowing free course on #{users.count} users."
  users.each do |u|
    puts u
    e = Enrollment.where(enrollable_type: "Assembly", enrollable_id: enrollable, user_id: u).first_or_create
    e.save!
    puts e.inspect
  end
end