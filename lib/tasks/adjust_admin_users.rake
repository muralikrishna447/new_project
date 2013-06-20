require 'fileutils'

task :adjust_admin_users => :environment do
  Rails.logger.level = Logger::DEBUG

  AdminUser.all.each do |au|
    puts "#{au.email} #{au.id}"
    u = User.where(email: au.email).first_or_create(password: "NEEDSRESET", password_confirmation: "NEEDSRESET")
    u.role = :admin
    u.name ||= u.email
    u.save!
    puts "#{au.email} #{au.id} #{u ? u.id : '-'}"
  end

end