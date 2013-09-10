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