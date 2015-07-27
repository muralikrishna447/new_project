task :fill_algolia => [:environment]  do |t, args|
  Activity.reindex!
end