task :setup_stream => :environment do
  Event.find_each do |event|
    # event.group_type = event.determine_group_type
    # event.group_name = event.determine_group_name
    puts "PREPARING: #{event.inspect}"
    if event.save_group_type_and_group_name
      puts 'SAVED'
      puts event.inspect
    else
      puts 'ERROR WHILE SAVING'
    end
    puts '_________________________'
  end
end