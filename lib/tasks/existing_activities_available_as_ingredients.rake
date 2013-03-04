task :existing_activities_available_as_ingredients => :environment do
  Activity.all.each do |act|
    Ingredient.find_or_create_by_sub_activity_id(act.id)
  end
end