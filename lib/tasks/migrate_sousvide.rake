task :migrate_sousvide => :environment do
  course = Course.find(1)
  puts "Preparing to migrate Sous Vide Course"
  # assembly = Assembly.find('accelerated-sous-vide-cooking-course')

  # if assembly
  #   puts "Existing assembly: "
  #   puts assembly.inspect
  # else
  #   # Create assembly
  #   assembly = Assembly.new({
  #     title: course.title,
  #     description: course.description,
  #     short_description: course.short_description,
  #     image_id: course.image_id,
  #     youtube_id: course.youtube_id,
  #     assembly_type: 'Course'
  #   })

  #   if assembly.save
  #     puts "Built new assembly: "
  #     puts assembly.inspect
  #     puts "*********************"
  #   end
  # end

  assembly = Assembly.where(slug: 'accelerated-sous-vide-cooking-course').first_or_create({
    title: course.title,
    description: course.description,
    short_description: course.short_description,
    image_id: course.image_id,
    youtube_id: course.youtube_id,
    assembly_type: 'Course'
  })

  # Assign each activity to a variable
  course.inclusions.each do |inclusion|
    activity = inclusion.activity
    puts activity.inspect
    slug_underscore = activity.slug.gsub('-','_')
    instance_variable_set("@#{slug_underscore}",activity)
  end

  # Migrate Introduction
  group_introduction = Assembly.new({
    title: 'Introduction',
    assembly_type: 'Group'
  })

  if group_introduction.save
    puts "Saved Group: Introduction"
    attach_includable(assembly, group_introduction)

    [@what_is_sous_vide, @why_sous_vide_convenience, @why_sous_vide_consistency, @what_you_ll_need_thermometer, @five_basic_steps_for_sous_vide].each do |activity|
      attach_includable(group_introduction, activity)
    end
  end
  
  group_preparation = Assembly.new({
    title: 'Preparation',
    assembly_type: 'Group'
  })

  if group_preparation.save
    puts "Saved Group: Preparation"
    attach_includable(assembly, group_preparation)

    @group_whatyoullneed = Assembly.create({title: "What you'll need", assembly_type: 'Group'})

    [@preparation_overview, @get_organized, @work_clean, @group_whatyoullneed].each do |activity|
      attach_includable(group_preparation, activity)
    end
  end

end

def attach_includable(assembly, includable)
  inclusion = assembly.assembly_inclusions.new
  inclusion.includable = includable
  if inclusion.save
    puts "Saved Inclusion for:"
    puts assembly.inspect
  end
end