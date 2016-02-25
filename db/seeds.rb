require 'yaml'
require './lib/copy_creator'

def create_course(course)
  c = Course.create
  c.title = course[:title]
  c.description = course[:description]
  c.course_order = course[:order]
  c.published = true
  if course[:activities].present?
    course[:activities].each do |activity|
      a = Activity.find_by_title(activity[:title])
      c.activities << a
    end
  end
  c.save
  c
end

def create_activity(activity)
  a = Activity.create
  a.title = activity[:title]
  a.youtube_id = activity[:youtube_id]
  a.difficulty = activity[:difficulty]
  a.yield = activity[:yield]
  a.timing = activity[:timing]
  a.description = activity[:description]
  a.activity_order = activity[:order]
  a.published = true
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
  s.image_description = step[:image_description]
  s.directions = step[:directions]
  s.save
  s.update_attribute(:step_order, 0) 
  if step[:ingredients].present?
    step[:ingredients].each do |ingredient|
      item = create_ingredient(ingredient[:title])
      create_step_ingredient(s, item, ingredient[:display_quantity], ingredient[:unit])
    end
  end
  s
end

def create_admin(email, password)
  return if AdminUser.where(email: email).any?
  u = AdminUser.create
  u.email = email
  u.password = password
  u.save
  u
end

def create_user(email, password, name)
  return if User.where(email: email).any?
  u = User.create
  u.email = email
  u.password = password
  u.name = name
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
  ingredient = Ingredient.where(title: title).first
  return ingredient if ingredient
  ingredient = Ingredient.find_or_create_by_title(title)
  ingredient.product_url = product_url
  ingredient.save
  ingredient
end

def create_recipe(title, activity)
  return if Recipe.where(title: title).any?
  recipe = Recipe.create
  recipe.title = title
  recipe.activities << activity
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

def create_recipe_ingredient(recipe, ingredient, display_quantity, unit)
  a = RecipeIngredient.new
  a.recipe = recipe
  a.ingredient = ingredient
  a.display_quantity = display_quantity
  a.unit = unit
  a.save
end

def create_step_ingredient(step, ingredient, display_quantity, unit)
  a = StepIngredient.new
  a.step = step
  a.ingredient = ingredient
  a.display_quantity = display_quantity
  a.unit = unit
  a.save!
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
          create_recipe_ingredient(recipe, item, ingredient[:display_quantity], ingredient[:unit])
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

  activity.update_recipe_steps
end

def build_course(course_data)
  return if Course.where(title: course_data[:title]).any?
  course = create_course(course_data)
end

def build_admin(admin_data)
  create_admin(admin_data[:email], admin_data[:password])
end

def build_user(user_data)
  create_user(user_data[:email], user_data[:password], user_data[:name])
end

def parse_data(name)
  HashWithIndifferentAccess.new(YAML::load(File.open(File.join(Rails.root, "db", name))))
end

@seed_data = parse_data('seeds.yml')

=begin
@seed_data[:activities].each do |activity_data|
  build_activity(activity_data)
end

@seed_data[:courses].each do |course_data|
  build_course(course_data)
end
=end

CopyCreator.create

Version.create unless Version.any?
PrivateToken.create(token: PrivateToken.new_token_string) unless PrivateToken.any?

