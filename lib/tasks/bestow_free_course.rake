task :bestow_free_course, [:course_slug, :user_email] => [:environment]  do |t, args|
  enrollable = Assembly.find(args.course_slug)
  user = User.find_by_email(args.user_email)
  e = Enrollment.where(enrollable_type: "Assembly", enrollable_id: enrollable, user_id: user.id).first_or_create
  e.save!
  puts e.inspect
end