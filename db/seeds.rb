def create_activity(activity)
  a = Activity.create
  a.title = activity[:title]
  a.youtube_id = activity[:youtube_id]
  a.difficulty = activity[:difficulty]
  a.yield = activity[:yield]
  a.timing = activity[:timing]
  a.description = activity[:description]
  a.save
  a
end

def create_step(step)
  s = Step.create
  s.activity = step[:activity]
  s.recipe = step[:recipe]
  s.title = step[:title]
  s.youtube_id = step[:youtube_id]
  s.save

  step[:ingredients].each do |ingredient|
    item = create_ingredient(ingredient[:title])
    create_step_ingredient(s, item, ingredient[:quantity], ingredient[:unit])
  end

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

def create_recipe(title, activity)
  r  = Recipe.create
  r.title = title
  r.activity = activity
  r.save
  r
end

def create_activity_equipment(activity, equipment)
  a = ActivityEquipment.new
  a.activity = activity
  a.equipment = equipment
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

def create_bourbon_glazed_step_by_step
  glaze = {
    title: "Bourbon Glazed Smoked Chicken Breast",
    youtube_id: "TvdqT6FMmgw",
    difficulty: "Easy",
    description: "dio twee umami chambray. Velit VHS ad godard PBR american
    apparel. Placeat odio leggings typewriter chambray master cleanse squid,
    aesthetic seitan ullamco bicycle rights pour-over mlkshk cardigan ea.
    Mollit bushwick brunch, scenester et direct trade carles eu portland cosby
    sweater ennui shoreditch. Laboris velit gluten-free, pork belly bicycle
    rights twee nulla mumblecore cosb",
    yield: "800g(~4 portions)",
    timing: "74 hours overall including 34 mins preperation and 35 misn to reheat and finish"
  }

  activity_equipment = [
    {title: "Smoker", product_url: "http://www.amazon.com/dp/B00104WRCY/?tag=hyprod-20&hvadid=15475540419&hvpos=1o2&hvexid=&hvnetw=g&hvrand=15365057922131986741&hvpone=&hvptwo=&hvqmt=&ref=asc_df_B00104WRCY"},
    {title: "Brine Tank"},
    {title: "Sous Vide Equipment"}
  ]

  activity = create_activity(glaze)

  recipes = [
    {title: "Mop Sauce",
     ingredients: [
        {title: "Chicken jus", quantity: 410, unit: 'g' },
        {title: "Cider vinegar", quantity: 120, unit: 'g' },
        {title: "Golden brown sugar", quantity: 100, unit: 'g' },
        {title: "Black strap molasses", quantity: 60, unit: 'g' },
        {title: "Worchestershire", quantity: 45, unit: 'g' },
        {title: "Ginger powder", quantity: 0.80, unit: 'g' },
        {title: "Allspice powder", quantity: 0.75, unit: "g" }
     ],
      steps: [ ]
    },
    {title: "Awesome Sauce",
     ingredients: [
        {title: "Chicken jus", quantity: 410, unit: 'g' },
        {title: "Cider vinegar", quantity: 120, unit: 'kg' },
        {title: "Other aweome ingredient", quantity: 100, unit: 'g' },
        {title: "Black strap molasses", quantity: 60, unit: 'g' },
        {title: "Worchestershire", quantity: 45, unit: 'g' },
        {title: "Ginger powder", quantity: 0.80, unit: 'g' },
        {title: "Allspice powder", quantity: 0.75, unit: "g" }
     ],
      steps: [
        {title: 'Make the sauce',
        youtube_id: "TvdqT6FMmgw",
        ingredients: [
          {title: "Chicken jus", quantity: 410, unit: 'g' },
          {title: "Cider vinegar", quantity: 120, unit: 'kg' },
          {title: "Other aweome ingredient", quantity: 100, unit: 'g' },
          {title: "Black strap molasses", quantity: 60, unit: 'g' },
          {title: "Worchestershire", quantity: 45, unit: 'g' },
        ]
        }
     ]
    }
  ]

  activity_steps = [
    { activity: activity,
      title: "Trim the breast meat",
      youtube_id: "TvdqT6FMmgw",
      ingredients: []
    }
  ]


  activity_equipment.each do |equipment|
    item = create_equipment(equipment[:title], equipment[:product_url])
    create_activity_equipment(activity, item)
  end

  recipes.each do |r|
    recipe = create_recipe(r[:title], activity)
    r[:ingredients].each do |ingredient|
      item = create_ingredient(ingredient[:title])
      create_recipe_ingredient(recipe, item, ingredient[:quantity], ingredient[:unit])
    end
    r[:steps].each do |step|
      step[:recipe] = recipe
      create_step(step)
    end
  end

  activity_steps.each do |step|
    create_step(step)
  end

end

create_admin('shaun@substantial.com', 'asdfasdf')
create_admin('aaron@substantial.com', 'asdfasdf')
create_bourbon_glazed_step_by_step
create_activity({title:"Lecture", youtube_id: 'ydOB-YNJ8Jw'})
