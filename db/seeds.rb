def create_activity(title, video_url='')
  a = Activity.create
  a.title = title
  a.video_url = video_url
  a.save
  a
end

def create_step(activity, title='', video_url='')
  s = Step.create
  s.activity = activity
  s.title = title
  s.video_url = video_url
  s.save
  s
end

def create_admin
  u = User.create
  u.email = "admin@admin.org"
  u.password = 'asdfasdf'
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

def create_activity_ingredient(activity, ingredient, quantity)
  a = ActivityIngredient.new
  a.activity = activity
  a.ingredient = ingredient
  a.quantity = quantity
  a.save
end

def create_bourbon_glazed_step_by_step
  activity_equipment = [
    {title: "Smoker", product_url: "http://www.amazon.com/dp/B00104WRCY/?tag=hyprod-20&hvadid=15475540419&hvpos=1o2&hvexid=&hvnetw=g&hvrand=15365057922131986741&hvpone=&hvptwo=&hvqmt=&ref=asc_df_B00104WRCY"},
    {title: "Brine Tank"},
    {title: "Sous Vide Equipment"}
  ]

  activity_ingredients = [
    {title: "Heinz Ketchup", quantity: "600g" },
    {title: "Chicken jus", quantity: "410g" },
    {title: "Cider vinegar", quantity: "120g" },
    {title: "Golden brown sugar", quantity: "100g" },
    {title: "Black strap molasses", quantity: "60g" },
    {title: "Worchestershire", quantity: "45g" },
    {title: "Ginger powder", quantity: "0.80g" },
    {title: "Allspice powder", quantity: "0.75g" }
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
  activity = create_activity("Bourbon Glazed Smoked Chicken Breast", "TvdqT6FMmgw")

  activity_equipment.each do |equipment|
    item = create_equipment(equipment[:title], equipment[:product_url])
    create_activity_equipment(activity, item)
  end

  activity_ingredients.each do |ingredient|
    item = create_ingredient(ingredient[:title])
    create_activity_ingredient(activity, item, ingredient[:quantity])
  end

  steps.each do |step|
    create_step(activity, step[:title], step[:video])
  end

end

create_admin
create_bourbon_glazed_step_by_step
create_activity("Lecture", 'ydOB-YNJ8Jw')
