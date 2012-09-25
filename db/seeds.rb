require 'yaml'

def create_activity(activity)
  a = Activity.create
  a.title = activity[:title]
  a.youtube_id = activity[:youtube_id]
  a.difficulty = activity[:difficulty]
  a.yield = activity[:yield]
  a.timing = activity[:timing]
  a.description = activity[:description]
  a.activity_order = activity[:order]
  a.save
  a
end

def create_step(step)
  s = Step.create
  s.activity = step[:activity]
  s.recipe = step[:recipe]
  s.title = step[:title]
  s.youtube_id = step[:youtube_id]
  s.image_id = step[:image_id]
  s.directions = step[:directions]
  s.save
  s.update_attribute(:step_order_position, :last)
  if step[:ingredients].present?
    step[:ingredients].each do |ingredient|
      item = create_ingredient(ingredient[:title])
      create_step_ingredient(s, item, ingredient[:quantity], ingredient[:unit])
    end
  end
  s
end

def create_admin(email, password)
  return if User.where(email: email).any?
  u = User.create
  u.email = email
  u.password = password
  u.save
  u
end

def create_equipment(title, product_url)
  return if Equipment.where(title: title).any?
  e = Equipment.find_or_create_by_title(title)
  e.product_url = product_url
  e.save
  e
end

def create_ingredient(title, product_url='')
  return if Ingredient.where(title: title).any?
  ingredient = Ingredient.find_or_create_by_title(title)
  ingredient.product_url = product_url
  ingredient.save
  ingredient
end

def create_recipe(title, activity)
  return if Recipe.where(title: title).any?
  recipe  = Recipe.create
  recipe.title = title
  recipe.activity = activity
  recipe.save
  recipe
end

def create_activity_equipment(activity, equipment, optional)
  a = ActivityEquipment.new
  a.activity = activity
  a.equipment = equipment
  a.optional = optional.present? && optional
  a.save
end

def create_recipe_ingredient(recipe, ingredient, quantity, unit)
  a = RecipeIngredient.new
  a.recipe = recipe
  a.ingredient = ingredient
  a.quantity = quantity
  a.unit = unit
  a.save
end

def create_step_ingredient(step, ingredient, quantity, unit)
  a = StepIngredient.new
  a.step = step
  a.ingredient = ingredient
  a.quantity = quantity
  a.unit = unit
  a.save
end

def build_activity(activity_data)
  return if Activity.where(title: activity_data[:title]).any?
  activity = create_activity(activity_data)
  if activity_data[:activity_equipment].present?
    activity_data[:activity_equipment].each do |equipment|
      item = create_equipment(equipment[:title], equipment[:product_url])
      create_activity_equipment(activity, item, equipment[:optional])
    end
  end

  if activity_data[:activity_steps].present?
    activity_data[:activity_steps].each do |step|
      step[:activity] = activity
      create_step(step)
    end
  end

  if activity_data[:recipes].present?
    activity_data[:recipes].each do |r|
      recipe = create_recipe(r[:title], activity)
      if r[:ingredients].present?
        r[:ingredients].each do |ingredient|
          item = create_ingredient(ingredient[:title])
          create_recipe_ingredient(recipe, item, ingredient[:quantity], ingredient[:unit])
        end
      end
      if r[:steps].present?
        r[:steps].each do |step|
          step[:recipe] = recipe
          create_step(step)
        end
      end
    end
  end
end

def build_admin(admin_data)
  create_admin(admin_data[:email], admin_data[:password])
end

@seed_data = HashWithIndifferentAccess.new(YAML::load(File.open(File.join(Rails.root, "db", "seeds.yml"))))

@seed_data[:admins].each do |admin|
  build_admin(admin)
end

@seed_data[:activities].each do |activity_data|
  build_activity(activity_data)
end

@seed_data[:copy].each do |content|
  next if Copy.where(location: content[:location]).any?
  c = Copy.find_or_create_by_location(content[:location])
  c.copy= content[:copy_content]
  c.save
  c
end

Version.create unless Version.any?

