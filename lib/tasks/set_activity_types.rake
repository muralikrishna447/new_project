task :set_activity_types => :environment do
  activity_types = Activity::TYPES

  recipe_ids = [
    1, # Salmon 104
    2, # Salmon mi-cuit
    3, # Pickled Onions
    4, # Watercress Puree
    5, # Horseradish Cream
  ]
  recipes = Activity.find(recipe_ids)
  recipes.each do |recipe|
    if recipe.activity_type.include? 'Recipe'
      puts "#{recipe.title} is already a Recipe"
    else
      recipe.activity_type << 'Recipe'
      if recipe.save
        puts "Set #{recipe.title} as type Recipe"
      else
        puts "ERROR: Could not set #{recipe.title} as type Recipe"
      end
    end
    p recipe
    puts "___________________________"
  end

  technique_ids = [
    42, # How to Sharpen a knife
    60 # How and when to portion a fish
  ]
  techniques = Activity.find(technique_ids)
  techniques.each do |technique|
    if technique.activity_type.include? 'Technique'
      puts "#{technique.title} is already a Technique"
    else
      technique.activity_type << 'Technique'
      if technique.save
        puts "Set #{technique.title} as type Technique"
      else
        puts "ERROR: Could not set #{technique.title} as type Technique"
      end
    end
    p technique
    puts "___________________________"
  end
end