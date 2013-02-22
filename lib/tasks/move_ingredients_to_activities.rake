task :move_ingredients_to_activities => :environment do
  # The activity_id column in activity_ingredients is actually still pointing to recipe ids. I've verified externally
  # that there are no recipes used in multiple activities, and above I've created activities for any recipes that
  # aren't used in any activities. So now, go fix up all those ids.
  to_save = []
  to_del = []
  ActivityIngredient.all.each do |ai|
    p ai
    recipe = Recipe.find_by_id(ai.activity_id)
    if recipe
      ai.activity_id = recipe.activities.first.id
      to_del << ai
      to_save << ai.clone
    end
  end
  to_del.each do |ai|
    puts "destroying #{ai.inspect}"
    ai.destroy
    #execute  "DELETE FROM `activity_ingredients` WHERE `activity_ingredients`.`id` = #{ai.id}"
  end
  to_save.each_with_index do |ai, idx|
    puts "saving  #{ai.inspect}"
    ai.save
    #execute  "UPDATE  `activity_ingredients` SET `activity_id` = #{ai.activity_id} WHERE `activity_ingredients`.`id` = #{idx}"
  end
end