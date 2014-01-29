task :remove_duplicate_badges => :environment do
  badges = Merit::Badge.all
  badges.each do |badge|
    badge.users.each do |user|
      number_of_badges = user.badges.select{|b| b.id == badge.id}.count
      if number_of_badges > 1
        (number_of_badges - 1).times do
          puts "Remove Badge with ID: #{badge.id}"
          puts "From User with ID: #{user.id}"
          puts "************************"
          user.rm_badge(badge.id)
        end
      end
    end
  end
end