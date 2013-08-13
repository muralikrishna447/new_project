task :generate_group_name_and_type => :environment do
  Event.find_each do |event|
    event.group_type = event.determine_group_type
    event.group_name = event.determine_group_name
    if event.save
      puts 'SAVED'
      puts event.inspect
    else
      puts 'ERROR WHILE SAVING'
    end
    puts '_________________________'
  end
end