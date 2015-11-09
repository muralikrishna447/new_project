task :migrate_enrollments_to_memberships => [:environment] do

  premium_start_date = DateTime.new(2015, 11, 18)
  count = 0

  Enrollment.where('(price > 0) OR (gift_certificate_id IS NOT NULL)').group_by(&:user_id).each do |result|
    u = User.find(result[0])
    next if u.premium_member
    u.premium_member = true
    u.premium_membership_created_at = premium_start_date
    # Three users that already don't pass validation so can't be resaved; not fixing right now
    u.save(validate: false)
    puts "Granting premium membership to: #{u.email}"
    count += 1
  end

  puts "Total new premium memberships: #{count}"

end