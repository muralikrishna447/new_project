require 'csv'

namespace :activities do

  task :csv => :environment do
    activities = Activity.published.chefsteps_generated.all
    activities_csv = []
    activities.each do |activity|
      url = "https://www.chefsteps.com/activities/#{activity.slug}"
      activities_csv << [activity.id, activity.title, url]
    end
    CSV.open("activities.csv", "w") do |csv|
      csv << ['id', 'title', 'url']
      activities_csv.each do |activity|
        csv << activity
      end
    end
  end

end