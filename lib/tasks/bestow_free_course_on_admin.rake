task :bestow_free_course_on_admin => :environment do
  users = User.where(role: "admin")
  enrollable = Assembly.find('french-macarons')
  puts "Bestowing free course on #{users.count} users."
  users.each do |u|
    puts u
    e = Enrollment.where(enrollable_type: "Assembly", enrollable_id: enrollable, user_id: u).first_or_create
    e.save!
    puts e.inspect
  end
end

task :bestow_siphon_to_forum => :environment do
  users = User.find([13092,571,832,1534,1369,9556,1639,13587,1329,8337,11970,1432,18331,331])
  enrollable = Assembly.find('whipping-siphons')
  puts "Bestowing free course on #{users.count} users."
  users.each do |u|
    puts u
    e = Enrollment.where(enrollable_type: "Assembly", enrollable_id: enrollable, user_id: u).first_or_create
    e.save!
    puts e.inspect
  end
end