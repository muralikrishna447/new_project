task :sousvide_inclusions => :environment do
  course = Course.find(1)
  # ids = []
  # course.inclusions.each do |inclusion|
  #   activity = inclusion.activity
  #   ids << activity.id
  # end
  # puts ids.join(',')
  ids = [61,15,27,28,51,35,54,110,62,46,47,48,52,26,53,50,60,135,65,58,116,130,181,67,68,193,457,70,186,177,72,129,73,6,80,81,84,85,29,17,75,76,86,10,12,23,87,88,89,90,92,7,93,1,34,118,56,94,9,117,55,13,14]
  activities = Activity.find(ids)
  puts activities.inspect
end

task :migrate_sousvide => :environment do
  course = Course.find(1)
  @quiz1 = Quiz.find(6)
  @quiz2 = Quiz.find(12)
  puts "Preparing to migrate Sous Vide Course"

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

  ids = [61,15,27,28,51,35,54,110,62,46,47,48,52,26,53,50,60,135,65,58,116,130,181,67,68,193,457,70,186,177,72,129,73,6,80,81,84,85,29,17,75,76,86,10,12,23,87,88,89,90,92,7,93,1,34,118,56,94,9,117,55,13,14]
  activities = Activity.find(ids)
  activities.each do |activity|
    slug_underscore = activity.slug.gsub('-','_')
    instance_variable_set("@#{slug_underscore}",activity) 
  end

  puts activities.inspect

  # Migrate Introduction
  group_introduction = Assembly.new({
    title: 'Introduction',
    assembly_type: 'Group'
  })

  if group_introduction.save
    puts "Saved Group: Introduction"
    attach_includable(assembly, group_introduction, 0)

    [@what_is_sous_vide, @why_sous_vide_convenience, @why_sous_vide_consistency, @what_you_ll_need_thermometer, @five_basic_steps_for_sous_vide, @module_1_summary, @quiz1].each_with_index do |activity, index|
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

    [@preparation_overview, @get_organized, @work_clean, @group_whatyoullneed, @group_portioning, @group_pretreatments, @module_2_summary, @quiz2].each_with_index do |activity, index|
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

    @group_rigidcontainers = Assembly.create({title: "Rigid Containers", assembly_type: 'Group'})
    [@aerated_green_apple_sorbet].each_with_index do |activity, index|
      attach_includable(@group_rigidcontainers, activity, index)
    end

    @group_improvisedstrategies = Assembly.create({title: "Improvised Strategies", assembly_type: 'Group'})
    [@simple_sous_vide_packaging].each_with_index do |activity, index|
      attach_includable(@group_improvisedstrategies, activity, index)
    end

    [@group_whypackagefood, @group_vacuumpacking, @group_rigidcontainers, @group_improvisedstrategies].each_with_index do |activity, index|
      attach_includable(group_packaging, activity, index)
    end
  end

  # Migrate Cooking Temperature
  group_cookingtemperature = Assembly.new({
    title: 'Cooking Temperature',
    assembly_type: 'Group'
  })

  if group_cookingtemperature.save
    puts "Saved Group: Cooking Temperature"
    attach_includable(assembly, group_cookingtemperature, 3)

    @group_selectingacookingtemperature = Assembly.create({title: "Selecting a Cooking Temperature", assembly_type: 'Group'})
    [@sous_vide_steak, @short_ribs_time_and_temp].each_with_index do |activity, index|
      attach_includable(@group_selectingacookingtemperature, activity, index)
    end

    @group_temperatureimprovisedstrategies = Assembly.create({title: "Temperature: Improvised Strategies", assembly_type: 'Group'})
    [@improvised_sous_vide_pot_on_a_stove_method, @improvised_sous_vide_insulated_cooler_method, @improvised_sous_vide_running_water_method].each_with_index do |activity, index|
      attach_includable(@group_temperatureimprovisedstrategies, activity, index)
    end

    [@group_selectingacookingtemperature, @group_temperatureimprovisedstrategies].each_with_index do |activity, index|
      attach_includable(group_cookingtemperature, activity, index)
    end
  end

  # Migrate Finishing Strategies
  group_finishingstrategies = Assembly.new({
    title: 'Finishing Strategies',
    assembly_type: 'Group'
  })

  if group_finishingstrategies.save
    puts "Saved Group: Finishing Strategies"
    attach_includable(assembly, group_finishingstrategies, 4)

    @group_simplesousvidedishes = Assembly.create({title: "Simple Sous Vide Dishes", assembly_type: 'Group'})
    [@simple_sous_vide_vegetables].each_with_index do |activity, index|
      attach_includable(@group_simplesousvidedishes, activity, index)
    end

    @group_intermediatesousvidedishes = Assembly.create({title: "Intermediate Sous Vide Dishes", assembly_type: 'Group'})
    [@salmon_104_f, @pork_cheek_celery_root_and_pickled_apple, @green_eggs_and_ham, @red_wine_poached_pear].each_with_index do |activity, index|
      attach_includable(@group_intermediatesousvidedishes, activity, index)
    end

    @group_advancedsousvidedishes = Assembly.create({title: "Advanced Sous Vide Dishes", assembly_type: 'Group'})
    [@sous_vide_pastrami].each_with_index do |activity, index|
      attach_includable(@group_advancedsousvidedishes, activity, index)
    end

    @group_traditionalrecipes = Assembly.create({title: "Traditional Recipes", assembly_type: 'Group'})
    [@pomme_rosti].each_with_index do |activity, index|
      attach_includable(@group_traditionalrecipes, activity, index)
    end

    [@group_simplesousvidedishes, @group_intermediatesousvidedishes, @group_advancedsousvidedishes, @group_traditionalrecipes].each_with_index do |activity, index|
      attach_includable(group_finishingstrategies, activity, index)
    end
  end

  # Migrate Choosing Equipment
  group_choosingequipment = Assembly.new({
    title: 'Choosing Equipment',
    assembly_type: 'Group'
  })

  if group_choosingequipment.save
    puts "Saved Group: Choosing Equipment"
    attach_includable(assembly, group_choosingequipment, 5)

    [@choosing_a_thermometer, @choosing_a_scale].each_with_index do |activity, index|
      attach_includable(group_choosingequipment, activity, index)
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