task :enrollment_stats => [:environment]  do |t, args|
  ages = Hash.new(0)
  Assembly.where("price > 0").each do |c|
    enrollments = Enrollment.where(enrollable_id: c.id).where("price > 0").order("created_at asc")
    next if enrollments.count < 10
    # don't use .first b/c there are usually some test sales earlier
    launch_day = enrollments[10].created_at.in_time_zone("America/Los_Angeles")
    launch_day_enrollments = enrollments.where(created_at: (launch_day.beginning_of_day...launch_day.end_of_day))
    new_users = launch_day_enrollments.joins(:user).merge(User.where(created_at: (launch_day.beginning_of_day...launch_day.end_of_day)))

    puts "---------- #{c.slug}"
    puts "Launch day #{launch_day.inspect}"
    puts "Total paid enrollments: #{enrollments.count}"
    puts "Day 1 paid enrollments: #{launch_day_enrollments.count}"
    puts "Day 1 paid enrollments for new users: #{new_users.count}"
  end
end