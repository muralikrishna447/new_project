task :create_from_aweber => :environment do
  all_emails = []
  to_create = []
  CSV.foreach("aweber.csv") do |email|
    all_emails << email[0] unless email.blank?
  end
  puts all_emails.last
  puts all_emails.last.class
  existing = User.where('email IN (?)', all_emails)
  to_create = all_emails - existing.map(&:email)

  to_create.each do |email|
    user = User.new
    user.email = email
    user.from_aweber = true
    user.name = email.split('@').first
    user.password = "learnsousvide"
    if user.save!
      puts "Created user #{user.inspect}"
    else
      puts "Failed to create #{user.inspect}"
    end
    puts "________________________________________"
  end
end