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

  assembly.assembly_inclusions.each do |inclusion|
    inclusion.destroy
  end

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
    attach_includable(assembly, group_introduction, 0)

    [@what_is_sous_vide, @why_sous_vide_convenience, @why_sous_vide_consistency, @what_you_ll_need_thermometer, @five_basic_steps_for_sous_vide].each_with_index do |activity, index|
      attach_includable(group_introduction, activity, index)
    end
  end

  # Migrate Preparation
  
  group_preparation = Assembly.new({
    title: 'Preparation',
    assembly_type: 'Group'
  })

  if group_preparation.save
    puts "Saved Group: Preparation"
    attach_includable(assembly, group_preparation, 1)

    @group_whatyoullneed = Assembly.create({title: "What you'll need", assembly_type: 'Group'})
    [@what_you_ll_need_scale, @weight_vs_volume_speed, @weight_vs_volume_accuracy].each_with_index do |activity, index|
      attach_includable(@group_whatyoullneed, activity, index)
    end

    @group_portioning = Assembly.create({title: "Portioning", assembly_type: 'Group'})
    [@portioning, @how_and_when_to_portion_fish, @butchery_halibut].each_with_index do |activity, index|
      attach_includable(@group_portioning, activity, index)
    end

    @group_pretreatments = Assembly.create({title: "Pretreatments", assembly_type: 'Group'})
    [@pretreatments_prior_to_cooking, @presearing_for_sous_vide, @equilibrium_brining].each_with_index do |activity, index|
      attach_includable(@group_pretreatments, activity, index)
    end

    [@preparation_overview, @get_organized, @work_clean, @group_whatyoullneed, @group_portioning, @group_pretreatments].each_with_index do |activity, index|
      attach_includable(group_preparation, activity, index)
    end
  end

  # Migrate Packaging
  group_packaging = Assembly.new({
    title: 'Packaging',
    assembly_type: 'Group'
  })

  if group_packaging.save
    puts "Saved Group: Packaging"
    attach_includable(assembly, group_packaging, 2)

    @group_whypackagefood = Assembly.create({title: "Why Package Food?", assembly_type: 'Group'})
    [@why_package_food_keeping_ingredients_fresh, @why_package_food_keeping_our_meals_healthy].each_with_index do |activity, index|
      attach_includable(@group_whypackagefood, activity, index)
    end

    @group_vacuumpacking = Assembly.create({title: "Vacuum Packing", assembly_type: 'Group'})
    [@how_chamber_style_vacuum_sealers_work, @vacuum_compression_of_plant_foods].each_with_index do |activity, index|
      attach_includable(@group_vacuumpacking, activity, index)
    end

    [@group_whypackagefood, @group_vacuumpacking].each_with_index do |activity, index|
      attach_includable(group_packaging, activity, index)
    end
  end

end

def attach_includable(assembly, includable, index)
  inclusion = assembly.assembly_inclusions.new
  inclusion.includable = includable
  inclusion.position = index
  if inclusion.save
    puts "Saved Inclusion for:"
    puts assembly.inspect
  end
end