task :setup_spherification => :environment do
  
  course = Course.find('spherification')
  course.published = true
  if course.save
    puts 'Published Course:'
    puts course.inspect
  end

  course.activities.each do |activity|
    activity.published = true
    if activity.save
      puts 'Published Activity'
      puts activity.inspect
    end
  end
end