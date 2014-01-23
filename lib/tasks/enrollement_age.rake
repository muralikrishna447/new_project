task :enrollment_age => [:environment]  do |t, args|
  ages = Hash.new(0)
  Enrollment.all.each do |e|
    if e.price > 0
      u = e.user
      ages[((e.created_at - u.created_at)/(60*60*24)).to_i] += 1 if u
    end
  end
  (0..500).each do |x|
    puts "#{x}, #{ages[x]}"
  end
end