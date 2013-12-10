task :migrate_sousvide => :environment do
  course = Course.find(1)
  puts "Preparing to migrate Sous Vide Course"

  # Create assembly
  assembly = Assembly.new({
    title: course.title,
    description: course.description,
    short_description: course.short_description,
    image_id: course.image_id,
    youtube_id: course.youtube_id,
    assembly_type: 'Course'
  })

  if assembly.save
    puts "Built new assembly: "
    puts assembly.inspect
    puts "*********************"
  end

  course.inclusions.each do |inclusion|
    activity = inclusion.activity
    puts activity.inspect
    slug_underscore = activity.slug.gsub('-','_')
    instance_variable_set("@#{slug_underscore}",activity)
  end

  puts @introduction.inspect
end