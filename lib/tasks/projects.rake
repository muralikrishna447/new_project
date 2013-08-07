task :create_project_salmon_104 => :environment do
  activity_ids = [
    1, # Salmon 104
    2, # Salmon mi-cuit
    3, # Pickled Onions
    4, # Watercress Puree
    5 # Horseradish Cream
  ]

  assembly = Assembly.new
  assembly.title = 'Salmon 104'
  assembly.description = 'Our first advanced recipe at ChefSteps.'
  assembly.assembly_type = 'Project'
  assembly.youtube_id = '2ZJ45YC1Oak'
  assembly.save

  puts 'Saved:'
  puts assembly.inspect
  puts '--------------------------------'

  activity_ids.each do |activity_id|
    inclusion = assembly.assembly_inclusions.new
    inclusion.includable_type = 'Activity'
    inclusion.includable_id = activity_id
    inclusion.save

    puts 'Saved'
    puts inclusion.inspect
    puts '--------------------------------'
  end

  puts 'Created Project'
  puts assembly.inspect
  puts assembly.assembly_inclusions.inspect
  puts '--------------------------------'
end