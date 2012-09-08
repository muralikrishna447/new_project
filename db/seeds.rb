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
end

create_admin

lecture = create_activity("Lecture", 'http://www.youtube.com/embed/ydOB-YNJ8Jw')
create_step(lecture, 'Weeze the Juice')
create_step(lecture, 'Do stuff', 'http://www.youtube.com/embed/ydOB-YNJ8Jw')
