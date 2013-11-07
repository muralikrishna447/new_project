namespace :courses do

  task :migrate_all => :environment do
    courses = ['science-of-poutine', 'knife-sharpening', 'spherification']
    courses.each do |slug|
      migrate(slug)
    end
  end

  # Example Usage: rake courses:migrate['science-of-poutine']
  task :migrate_one, [:slug] => :environment do |t,args|
    migrate(args.slug)
  end

  def migrate(slug)
    course = Course.find(slug)
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
        assembly_type: 'Group',
        published: true
      })

      # group.activities = course_child_groups[index].map(&:activity)
      course_child_groups[index].map(&:activity).each_with_index do |activity, index|
        i = group.assembly_inclusions.new
        i.includable = activity
        i.position = index + 1
        i.save
      end

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
      inclusion.position = index + 1
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

  task :special_poutine => :environment do
    course = Assembly.find 'science-of-poutine'
    old_upload_page = Activity.find 'poutine-final-assignment'

    new_upload_page = Assignment.new({title: old_upload_page.title, description: old_upload_page.description})
    puts "Setting up Upload page:"
    puts new_upload_page.inspect
    puts "--------------------"

    new_upload_inclusion = AssemblyInclusion.new
    new_upload_inclusion.includable = new_upload_page
    new_upload_inclusion.assembly_id = 21
    new_upload_inclusion.position = course.assembly_inclusions.count + 1
    if new_upload_inclusion.save
      puts "Including upload into course:"
      puts new_upload_inclusion.inspect
      puts "--------------------"

      old_upload_inclusion = AssemblyInclusion.find(102)
      old_upload_inclusion.destroy

      puts "Deleted Old Upload Inclusion"
      puts "--------------------"
    end

  end

  task :special_knife => :environment do
    course = Assembly.find 'knife-sharpening'
    old_upload_page = Activity.find 'sharpen-and-post'

    new_upload_page = Assignment.new({title: old_upload_page.title, description: old_upload_page.description})
    puts "Setting up Upload page:"
    puts new_upload_page.inspect
    puts "--------------------"

    new_upload_inclusion = AssemblyInclusion.new
    new_upload_inclusion.includable = new_upload_page
    new_upload_inclusion.assembly_id = 25
    new_upload_inclusion.position = course.assembly_inclusions.count + 1
    if new_upload_inclusion.save
      puts "Including upload into course:"
      puts new_upload_inclusion.inspect
      puts "--------------------"

      old_upload_inclusion = AssemblyInclusion.find(112)
      old_upload_inclusion.destroy

      puts "Deleted Old Upload Inclusion"
      puts "--------------------"
    end

  end

  task :special_spherification => :environment do
    course = Assembly.find 'spherification'
    old_upload_page = Activity.find 'final-assignment'

    new_upload_page = Assignment.new({title: old_upload_page.title, description: old_upload_page.description})
    puts "Setting up Upload page:"
    puts new_upload_page.inspect
    puts "--------------------"

    new_upload_inclusion = AssemblyInclusion.new
    new_upload_inclusion.includable = new_upload_page
    new_upload_inclusion.assembly_id = 31
    new_upload_inclusion.position = course.assembly_inclusions.count + 1
    if new_upload_inclusion.save
      puts "Including upload into course:"
      puts new_upload_inclusion.inspect
      puts "--------------------"

      old_upload_inclusion = AssemblyInclusion.find(129)
      old_upload_inclusion.destroy

      puts "Deleted Old Upload Inclusion"
      puts "--------------------"
    end

  end

end