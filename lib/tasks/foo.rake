task :foo => [:environment]  do |t, args|
  enrollments = Enrollment.where("price > 0").where("gift_certificate_id IS NULL").order("created_at asc")
  t1 = (Time.now - 1.day).beginning_of_day
  t2 = t1.end_of_day
  puts t1
  puts t2
  enrollments = enrollments.where(created_at: (t1...t2)).includes(:user)
  gifts = GiftCertificate.where(created_at: (t1...t2)).includes(:user)
  charges = Stripe::Charge.all(count: 1000, paid: true, created: {gte: t1.to_i, lte: t2.to_i})

  e_ids = enrollments.map(&:user).map(&:stripe_id)
  g_ids = gifts.map(&:user).map(&:stripe_id)
  c_ids = charges.map(&:card).map(&:customer)

  puts "Enrollments #{e_ids.count}"
  puts "Gifts #{g_ids.count}"
  puts "Charges #{c_ids.count}"

  puts (c_ids - (e_ids + g_ids)).inspect
end