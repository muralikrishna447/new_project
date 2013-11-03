task :migrate_courses => :environment do
  course = Course.find 'science-of-poutine'
  puts "Preparing to migrate course: #{course.title}"

  # Build the main Assembly

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

  # Split out the different nesting levels
  course_nesting_parents = course.inclusions.to_a.select{|i| i.nesting_level == 0}
  course_child_groups = course.inclusions.split{|i| i.nesting_level == 0}.reject{|i| i.length == 0}


  course_nesting_parents.each_with_index do |parent, index|
    group = Assembly.new({
      title: parent.activity.title,
      description: parent.activity.description,
      image_id: parent.activity.image_id,
      youtube_id: parent.activity.youtube_id,
      assembly_type: 'Group'
    })

    group.activities = course_child_groups[index].map(&:activity)

    if group.save
      puts "Built new Group:"
      puts group.title
      puts "--------------------"
      puts "with activities:"
      puts group.activities.map(&:title)
      puts "**********************"
    end

    # Associate newly built group to the main assembly
    inclusion = assembly.assembly_inclusions.new
    inclusion.includable = group
    if inclusion.save
      puts "Associated group to main assembly:"
      puts inclusion.inspect
      puts " *********************"
    end
  end

  # Migrate Enrollments
  course.enrollments.each do |enrollment|
    enrollment.enrollable = assembly
    if enrollment.save
      puts "Migrated enrollment:"
      puts enrollment.inspect
      puts "***********************"
    end
  end

  # Migrate Uploads

  course.uploads.each do |upload|
    upload.assembly_id = assembly.id
    upload.course_id = nil
    if upload.save
      puts "Migrated upload:"
      puts upload.inspect
      puts "*************************"
    end
  end

end