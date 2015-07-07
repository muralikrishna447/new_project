require "csv"
require "open-uri"

task :ingest_tags, [:url] => :environment do |t, args|
  added_any = false
  CSV.new(open("#{args[:url]}/export?format=csv"), :headers => :first_row).each do |line|
    row = line.to_hash
    prefix = 'http://chefsteps.com/activities/' # in the spreadsheet so reviewers can click through
    slug = row['url'][prefix.length..-1]
    activity = Activity.find(slug)

    # Get rid of columns we don't need so we have a clean set of tags
    row.delete("url")
    row.delete("reviewed?")

    # Get rid of any tags that don't apply or that are already applied to this activity
    # not because it would hurt to apply them again, but this makes the report cleaner.
    row.delete_if { |k,v| v.blank? || activity.tag_list.include?(k)}

    # Apply any remaining tags
    if row.keys.length > 0
      puts "#{activity.title}: #{row.keys.join(', ')}"
      activity.tag_list.add(row.keys)
      activity.save!
      added_any = true
    end
  end

  puts "All tags already applied." if ! added_any
end

