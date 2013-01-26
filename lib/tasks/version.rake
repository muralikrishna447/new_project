task :update_version => :environment do
  current_version = Version.first
  "Updating current version from:"
  p current_version
  current_version.touch
  if current_version.save
    puts "Current version was update to:"
    p current_version
  end
end