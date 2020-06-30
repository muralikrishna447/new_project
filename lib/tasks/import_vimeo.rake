require "csv"
require "open-uri"

task :import_vimeo, [:url] => :environment do |t, args|
  CSV.new(open("#{args[:url]}/export?format=csv"), :headers => :first_row).each do |line|

    row = line.to_hash
    vimeo_id = row["vimeo_id"]
    youtube_id = row["youtube_id"]
    if vimeo_id && youtube_id
      puts "Processing YT: #{youtube_id}: #{row['Title']}"
      activities = Activity.where('youtube_id =?', youtube_id)
      if activities.length < 1
        puts "*** No activity found using that youtube id"
      else
        activities.each do |activity|
          activity.update_attributes(vimeo_id: vimeo_id)
          if activity.user.blank?
            puts "Updated activity #{activity.title} - https://www.chefsteps.com/activities/#{activity.slug}"
          end
        end
        puts "Updated #{activities.count} total activities including forks"
      end
    end
  end
end

