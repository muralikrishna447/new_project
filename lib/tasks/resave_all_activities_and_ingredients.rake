# To hit the save triggers so titles get stripped
task :resave_all_activities_and_ingredients => :environment do
  Ingredient.all.each { |i| i.save! }
  Activity.all.each { |a| a.save! }
end