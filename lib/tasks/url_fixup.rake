task :url_fixup, [:url] => :environment do |t, args|
  url_patterns = ['http://chefsteps.com', 'http://www.chefsteps.com', 'https://chefsteps.com']
  correct_url = 'https://www.chefsteps.com'

  url_patterns.each do |pattern|
    fixup_steps = Step.where("directions ILIKE '%#{pattern}%'")
    puts "Fixing up #{fixup_steps.size} steps"
    fixup_steps.each do |step|
      step.directions = step.directions.gsub(pattern, correct_url)
      step.save
      print "."
    end
    puts

    fixup_descriptions = Activity.where("description ILIKE '%#{pattern}%'")
    puts "Fixing up #{fixup_descriptions.size} activity descriptions"
    fixup_descriptions.each do |activity|
      activity.description = activity.description.gsub(pattern, correct_url)
      activity.save
      print "."
    end
    puts

    fixup_components = Component.where("meta::text ILIKE '%#{pattern}%'")
    puts "Fixing up #{fixup_components.size} components"
    fixup_components.each do |component|
      component.meta = eval(component.meta.to_s.gsub(pattern, correct_url))
      component.save
      print "."
    end
    puts
  end

end