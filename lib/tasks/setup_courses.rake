task :setup_spherification => :environment do
  
  course = Course.find('spherification')
  course.published = true
  if course.save
    puts 'Published Course:'
    puts course.inspect
  end

  (course.activities - course.activity_modules).each do |activity|
    activity.published = true
    if activity.save
      puts 'Published Activity'
      puts activity.inspect
    end
  end
end

task :setup_poutine => :environment do
  
  course = Course.find('science-of-poutine')
  course.published = true
  if course.save
    puts 'Published Course:'
    puts course.inspect
  end

  (course.activities - course.activity_modules).each do |activity|
    activity.published = true
    if activity.save
      puts 'Published Activity'
      puts activity.inspect
    end
  end
end