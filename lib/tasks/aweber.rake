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
    password = "learnsousvide"
    puts "Creating user #{user.inspect}"
    # user.save
  end
end