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

def create_equipment(title, product_url ='', optional=false, activity=nil)
  e = Equipment.create
  e.title = title
  e.product_url = product_url
  e.optional = optional
  e.activity = activity
  e.save
  e
end

def create_bourbon_glazed_step_by_step
  step_by_step = create_activity("Bourbon Glazed Smoked Chicken Breast", 'http://www.youtube.com/embed/ydOB-YNJ8Jw')
  create_step(step_by_step, 'Trim the breast meat')
  create_step(step_by_step, 'Prepare the brine', 'http://www.youtube.com/embed/ydOB-YNJ8Jw')
  create_step(step_by_step, 'Equilibrium brine', 'http://www.youtube.com/embed/ydOB-YNJ8Jw')
  create_step(step_by_step, 'Cook chicken breasts, sous vide')
  create_step(step_by_step, 'Prepare Mopping Sauce', 'http://www.youtube.com/embed/ydOB-YNJ8Jw')
  create_step(step_by_step, 'Prepare the Garnishing Spice Rub')
  create_step(step_by_step, 'Smoke Brined Chicken Breast')
  create_step(step_by_step, 'Finish and Package')

end

create_admin
create_step_by_step
create_activity("Lecture", 'http://www.youtube.com/embed/ydOB-YNJ8Jw')
