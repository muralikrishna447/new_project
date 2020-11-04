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
        assembly_type: 'Group'
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

    last_includable = course.assembly_inclusions.last.includable
    last_includable.assembly_inclusions.each do |inclusion|
      inclusion.destroy
      puts "Deleted Old Upload Inclusion"
      puts "--------------------"
    end

    new_upload_inclusion = AssemblyInclusion.new
    new_upload_inclusion.includable = new_upload_page
    new_upload_inclusion.assembly_id = last_includable.id
    new_upload_inclusion.position = 2
    if new_upload_inclusion.save
      puts "Including upload into course:"
      puts new_upload_inclusion.inspect
      puts "--------------------"
    end

    # Migrate Quiz
    quiz = Quiz.find 'poutine-quiz'
    new_quiz_inclusion = AssemblyInclusion.new
    new_quiz_inclusion.includable = quiz
    new_quiz_inclusion.assembly_id = last_includable.id
    new_quiz_inclusion.position = 1
    if new_quiz_inclusion.save
      puts "Saved quiz inclusion"
      puts new_quiz_inclusion.inspect
      puts "--------------------"
    end

    # Badges
    course.badge_id = 4
    if course.save
      course.uploads.each do |upload|
        upload.user.add_badge(4)
      end
    end

  end

  task :special_knife => :environment do
    course = Assembly.find 'knife-sharpening'
    old_upload_page = Activity.find 'sharpen-and-post'

    new_upload_page = Assignment.new({title: old_upload_page.title, description: old_upload_page.description})
    puts "Setting up Upload page:"
    puts new_upload_page.inspect
    puts "--------------------"

    last_includable = course.assembly_inclusions.last.includable
    last_includable.assembly_inclusions.each do |inclusion|
      inclusion.destroy
      puts "Deleted Old Upload Inclusion"
      puts "--------------------"
    end

    new_upload_inclusion = AssemblyInclusion.new
    new_upload_inclusion.includable = new_upload_page
    new_upload_inclusion.assembly_id = last_includable.id
    new_upload_inclusion.position = 2
    if new_upload_inclusion.save
      puts "Including upload into course:"
      puts new_upload_inclusion.inspect
      puts "--------------------"
    end

    # Migrate Quiz
    quiz = Quiz.find 'sharpening-quiz'
    new_quiz_inclusion = AssemblyInclusion.new
    new_quiz_inclusion.includable = quiz
    new_quiz_inclusion.assembly_id = last_includable.id
    new_quiz_inclusion.position = 1
    if new_quiz_inclusion.save
      puts "Saved quiz inclusion"
      puts new_quiz_inclusion.inspect
      puts "--------------------"
    end

    # Badges
    course.badge_id = 5

    # Knife add
    old_description = course.description
    new_description = old_description + '<hr /><a href="/knife-collection"><img alt="Sddgrd4aqzqgviiz9f1g?v=line" src="https://d3awvtnmmsvyot.cloudfront.net/api/file/sddgrD4AQzqGvIiZ9f1G?v=line" /></a><hr />'
    course.description = new_description
    if course.save
      course.uploads.each do |upload|
        upload.user.add_badge(5)
      end
    end

  end

  task :special_spherification => :environment do
    course = Assembly.find 'spherification'
    old_upload_page = Activity.find 'final-assignment'

    new_upload_page = Assignment.new({title: old_upload_page.title, description: old_upload_page.description})
    puts "Setting up Upload page:"
    puts new_upload_page.inspect
    puts "--------------------"

    last_includable = course.assembly_inclusions.last.includable
    last_includable.assembly_inclusions.each do |inclusion|
      inclusion.destroy
      puts "Deleted Old Upload Inclusion"
      puts "--------------------"
    end

    new_upload_inclusion = AssemblyInclusion.new
    new_upload_inclusion.includable = new_upload_page
    new_upload_inclusion.assembly_id = last_includable.id
    new_upload_inclusion.position = 2
    if new_upload_inclusion.save
      puts "Including upload into course:"
      puts new_upload_inclusion.inspect
      puts "--------------------"
    end

    quiz = Quiz.find 'spherification-quiz'
    new_quiz_inclusion = AssemblyInclusion.new
    new_quiz_inclusion.includable = quiz
    new_quiz_inclusion.assembly_id = last_includable.id
    new_quiz_inclusion.position = 1
    if new_quiz_inclusion.save
      puts "Saved quiz inclusion"
      puts new_quiz_inclusion.inspect
      puts "--------------------"
    end

    course.badge_id = 2
    course.save

    page = Page.new({title: "#{course.title} Ingredients Equipment"})
    page.content = ApplicationController.new.render_to_string(partial: 'assemblies/landing_spherification')
    page.save

  end

  # Script to convert an activity to a list view

  task :convert_to_list => :environment do
    slugs = ['squeaky-cheese-curd-science', 'the-science-of-spherification', 'how-knives-cut', 'the-benefits-of-sharp-knives--2', 'do-you-need-an-expensive-knife', 'how-to-sharpen-a-knife', 'sharp-knives-are-fun']
    slugs.each do |slug|
      activity = Activity.find(slug)
      if activity
        convert_one_to_list(activity)
      end
    end
  end

  def convert_one_to_list(activity)
    puts "Converting activity to list view:"
    title = activity.title
    description = activity.description
    image = activity.featured_image_id

    # Update activity to use list view
    activity.layout_name = 'list'
    if activity.save
      puts activity.inspect
    end

    # # Bump step order if there are any steps

    # if activity.steps.length > 0
    #   activity.steps.each_with_index do |step,index|
    #     step.step_order = index + 1
    #     step.save
    #   end
    # end

    # # Create step
    # image_url = JSON.parse(image)['url'].gsub('www.filepicker.io','d3awvtnmmsvyot.cloudfront.net')
    # directions = "<h4>#{title.upcase}</h4><img src='#{image_url}'><hr/>#{description}"
    # puts directions
    # step = Step.new({directions: directions, image_id: image, activity_id: activity.id})
    # step.step_order = 0
    # if step.save
    #   puts step.inspect
    # end
    puts "----------------"
  end

  task :publish_all => :environment do
    slugs = ['spherification', 'science-of-poutine', 'knife-sharpening']
    new_classes = Assembly.where(slug: slugs)
    courses = Course.where(slug: slugs)
    new_classes.each do |new_class|
      new_class.published = true
      new_class.save
    end

    courses.each do |course|
      course.published = false
      course.save
    end
    puts new_classes.inspect
    puts courses.inspect

  end

end
