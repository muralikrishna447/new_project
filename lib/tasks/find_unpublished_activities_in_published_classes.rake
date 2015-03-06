task :find_unpublished_activities_in_published_classes => [:environment]  do
  assemblies = Assembly.published
  activities = []
  assemblies.each do |assembly|
    activities = activities + assembly.leaf_activities
  end
  puts activities.count
  activities.uniq!
  puts activities.count
  activities.reject! { |a| a.published }
  puts activities.count
  activities.each do |a|
    puts "#{a.title}\t(#{a.slug})"
  end
end