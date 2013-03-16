# To hit the save triggers so titles get stripped
task :resave_all_activities_and_ingredients => :environment do
  Rails.logger.level = Logger::DEBUG
  Ingredient.all.each do |i|
    i.save!
  end
  Activity.all.each  do  |a|
    a.save!
  end
end