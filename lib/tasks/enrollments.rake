task :migrate_enrollments => :environment do
  enrollments = Enrollment.all
  enrollments.each do |enrollment|
    if enrollment.course_id
      puts "Enrollment to fix:"
      puts enrollment.inspect
      course = Course.find(enrollment.course_id)
      enrollment.enrollable = course
      if enrollment.save
        puts "Enrollment fixed to:"
        puts enrollment.inspect
      else
        puts "ERROR"
      end
      puts "-------------------------------"
    end
  end
end

task :remove_dupes => :environment do
  enrollments = Enrollment.all
  grouped = enrollments.group_by{ |e| [e.enrollable_type, e.enrollable_id, e.user_id]}
  grouped.values.each do |duplicates|
    if duplicates.count > 1
      puts "DUPLICATE"
      first = duplicates.shift
      puts "keeping this one: "
      puts first.inspect
      duplicates.each do |duplicate|
        puts "removing this: "
        puts duplicate.inspect
        puts duplicate.destroy
      end
      puts "*"*30
    end
  end
end