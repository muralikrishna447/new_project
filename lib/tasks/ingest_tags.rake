require "csv"
require "open-uri"

task :ingest_tags, [:url] => :environment do |t, args|
  added_any = false
  CSV.new(open("#{args[:url]}/export?format=csv"), :headers => :first_row).each do |line|

    row = line.to_hash
    id = row["id"]
    activity = Activity.find(id)

    # Get rid of columns we don't need so we have a clean set of tags
    row.delete("id")
    row.delete("title")
    row.delete("published")
    row.delete("link")

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

task :rename_tag, [:old_name, :new_name] => :environment do |t, args|
  Ingredient.tagged_with(args[:old_name]).each do |ingredient|
    ingredient.tag_list.add(args[:new_name])
    ingredient.tag_list.remove(args[:old_name])
  end

  Activity.tagged_with(args[:old_name]).each do |activity|
    activity.tag_list.add(args[:new_name])
    activity.tag_list.remove(args[:old_name])    
  end

  puts "Renamed #{args[:old_name]} to #{args[:new_name]}"
end

