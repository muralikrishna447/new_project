require "csv"
require "open-uri"

# takes a Google spreadsheet URL (needs to be public) and sets the short description
task :ingest_seo_descriptions, [:url] => :environment do |t, args|
  CSV.new(open("#{args[:url]}/export?format=csv"), :headers => :first_row).each do |line|
    row = line.to_hash
    prefix = 'http://chefsteps.com/activities/' # in the spreadsheet so reviewers can click through
    slug = row['url'][prefix.length..-1]
    
    unless row['SEO description'].nil? then
      activity = Activity.find(slug)    
      activity.short_description = row['SEO description'].force_encoding("utf-8")
      activity.save!
    end
  end

  puts "SEO descriptions updated!"
end