task :update_version => :environment do
  current_version = Version.first
  p current_version
  current_version.touch
  p current_version
end