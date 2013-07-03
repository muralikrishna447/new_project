require 'fileutils'

task :adjust_admin_users => :environment do
  Rails.logger.level = Logger::DEBUG

  AdminUser.all.each do |au|
    puts "#{au.email} #{au.id}"
    u = User.where(email: au.email).first_or_create(password: "NEEDSRESET", password_confirmation: "NEEDSRESET")
    u.role = :admin
    u.name ||= u.email
    u.save
    puts "#{au.email} #{au.id} #{u ? u.id : '-'}"
  end

  # NOTE THIS CAN ONLY BE RUN ONCE!!! It remaps the ids, if you run it twice all will be garbage.
  Activity.all.each do |a|
    a.last_edited_by = User.find_by_email(AdminUser.find(a.last_edited_by).email) if a.last_edited_by rescue "ok"
    a.currently_editing_user = User.find_by_email(AdminUser.find(a.currently_editing_user).email) if a.currently_editing_user rescue "ok"
  end

end