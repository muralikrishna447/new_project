task :set_activity_types => :environment do
  activity_types = Activity::TYPES

  recipe_ids = [
    1, # Salmon 104
    2, # Salmon mi-cuit
    3, # Pickled Onions
    4, # Watercress Puree
    5, # Horseradish Cream
    111, # Charred Rapini
    112, # Gigandes Beans with Romesco in Saffron Broth
    113, # Saffron Broth
    114, # Romesco
    115, # Sous Vide Potatoes and Leeks
    118, # Green Eggs and Ham
    119, # Brioche Bread
    122, # Banana Cream Pie
    123, # Banana Custard
    124, # Vanilla Wafers
    125, # Milk Foam
    126, # Spiced Poached Bananas
    127, # Brown Butter Powder
    128, # Chilled Tomato Soup
    129, # Aerated Green Apple Sorbet
    131, # Ultimate Roast Chicken
    132, # Braised Pork Belly
    133, # Crispy Pressure-Braised Pork
    134, # Kung Pao Carnitas
    136, # Whole Poached Chicken
    137, # Hollandaise
    139, # House Rub, Pork Chop
    164, # Roasted Chicken Breast
    165, # Dungeness Crab
    166, # Tete de Cochon
    168, # Charred Haricoverts
    169, # Gigandes Beans
    170, # House Rub - Charred Cauliflower
    171, # Banana Custard at Home
    173 # Byrrhgroni Cocktail
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
    60, # How and when to portion a fish
    70, # Vacuum packing
    71, #Edge sealing
    116, # Equilibrium Brining
    135, # Breaking Down a Halibut
    189 #Making Berry Drops with Liquid Nitrogen
  ]
  # techniques = Activity.find(technique_ids)
  techniques = Activity.where('id in(?)', technique_ids)
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

  science_ids = [
    120, # Food Science The Flavor of Grilling
    121 # The Physics of Freezing Liquid Nitrogen in a Vacuum
  ]
  sciences = Activity.find(science_ids)
  sciences.each do |science|
    if science.activity_type.include? 'Science'
      puts "#{science.title} is already a Science"
    else
      science.activity_type << 'Science'
      if science.save
        puts "Set #{science.title} as type Science"
      else
        puts "ERROR: Could not set #{science.title} as type Science"
      end
    end
    p science
    puts "___________________________"
  end
end