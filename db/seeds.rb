def create_activity(activity)
  a = Activity.create
  a.title = activity[:title]
  a.youtube_id = activity[:youtube_id]
  a.difficulty = activity[:difficulty]
  a.yield = activity[:yield]
  a.timing = activity[:timing]
  a.cooked_this_count = 0
  a.save
  a
end

def create_step(activity, title='', youtube_id='')
  s = Step.create
  s.activity = activity
  s.title = title
  s.youtube_id = youtube_id
  s.save
  s
end

def create_recipe(activity, title='')
  s = Recipe.create
  s.activity = activity
  s.title = title
  s.save
  s
end

def create_admin(email, password)
  u = User.create
  u.email = email
  u.password = password
  u.save
  u
end

def create_equipment(title, product_url ='', optional=false)
  e = Equipment.find_or_create_by_title(title)
  e.product_url = product_url
  e.optional = optional
  e.save
  e
end

def create_ingredient(title, product_url='')
  i = Ingredient.find_or_create_by_title(title)
  i.product_url = product_url
  i.save
  i
end

def create_activity_equipment(activity, equipment)
  a = ActivityEquipment.new
  a.activity = activity
  a.equipment = equipment
  a.save
end

def create_activity_ingredient(activity, ingredient, quantity, unit)
  a = ActivityIngredient.new
  a.activity = activity
  a.ingredient = ingredient
  a.quantity = quantity
  a.unit = unit
  a.save
end

def create_bourbon_glazed_step_by_step
  activity_equipment = [
    {title: "Smoker", product_url: "http://www.amazon.com/dp/B00104WRCY/?tag=hyprod-20&hvadid=15475540419&hvpos=1o2&hvexid=&hvnetw=g&hvrand=15365057922131986741&hvpone=&hvptwo=&hvqmt=&ref=asc_df_B00104WRCY"},
    {title: "Brine Tank"},
    {title: "Sous Vide Equipment"}
  ]

  activity_ingredients = [
    {title: "Heinz Ketchup", quantity: 600, unit: 'g' },
    {title: "Chicken jus", quantity: 410, unit: 'g' },
    {title: "Cider vinegar", quantity: 120, unit: 'g' },
    {title: "Golden brown sugar", quantity: 100, unit: 'g' },
    {title: "Black strap molasses", quantity: 60, unit: 'g' },
    {title: "Worchestershire", quantity: 45, unit: 'g' },
    {title: "Ginger powder", quantity: 0.80, unit: 'g' },
    {title: "Allspice powder", quantity: 0.75, unit: "g" }
  ]

  steps = [
    { title: "Trim the breast meat",
      video: "TvdqT6FMmgw"
    },
    { title: "Prepare the brine",
      video: "hLsazIkED2I"
    },
    { title: "Cook chicken breasts, sous vide"},
    { title: "Prepare Mopping Sauce",
      video: "hLsazIkED2I"
    },
    { title: "Prepare the Garninishing Spice Rub",
      video: "hLsazIkED2I"
    },
    { title: "Smoke Brined Chicken Breast"},
    { title: "Finish and Package"}
  ]

  glaze = {
    title: "Bourbon Glazed Smoked Chicken Breast",
    youtube_id: "TvdqT6FMmgw",
    difficulty: "Easy",
    yield: "800g(~4 portions)",
    timing: "74 hours overall including 34 mins preperation and 35 misn to reheat and finish"
  }
  activity = create_activity(glaze)

  activity_equipment.each do |equipment|
    item = create_equipment(equipment[:title], equipment[:product_url])
    create_activity_equipment(activity, item)
  end

  activity_ingredients.each do |ingredient|
    item = create_ingredient(ingredient[:title])
    create_activity_ingredient(activity, item, ingredient[:quantity], ingredient[:unit])
  end

  steps.each do |step|
    create_step(activity, step[:title], step[:video])
  end

end

create_admin('shaun@substantial.com', 'asdfasdf')
create_admin('aaron@substantial.com', 'asdfasdf')
create_bourbon_glazed_step_by_step
create_activity({title:"Lecture", youtube_id: 'ydOB-YNJ8Jw'})
