# This is way more complicated then it needs to be. Look at the older version of this same file if you
# want to see a more correct way. Just by bad luck, the kitchen created a recipe that violated a constraint
# this migration dependend on, and by the time we got it figured out, the production database was in a half-modified
# state that this now has to account for.

class AddRecipeStuffToActivity < ActiveRecord::Migration[5.2]
  def change
    # This fails if there is no activity ingredients table
    # drop_table  :activity_ingredients
    rename_table :recipe_ingredients, :activity_ingredients
    # This fails
    # execute "ALTER TABLE activity_ingredients ADD PRIMARY KEY (id);"
    rename_column :activity_ingredients, :recipe_id, :activity_id
    rename_index :activity_ingredients, "index_recipe_ingredients_on_ingredient_order", "index_activity_ingredients_on_ingredient_order"
    rename_index :activity_ingredients, "index_recipe_ingredients_on_recipe_id_and_ingredient_id", "index_activity_ingredients_on_activity_id_and_ingredient_id"

    # This fails if there is no Recipes
    # Recipe.all.each do |recipe|
    #   # create an activity for any recipe that didn't have one so we can move the ingredients and steps over
    #   puts recipe.title
    #   if recipe.activities.count == 0
    #     activity = Activity.create
    #     activity.title = recipe.title
    #     activity.yield = recipe.yield
    #     activity.recipes << recipe
    #     activity.save!
    #   end

    #   activity = recipe.activities.first
    #   activity.steps = recipe.steps
    #   activity.save!
    # end

    # # The activity_id column in activity_ingredients is actually still pointing to recipe ids. I've verified externally
    # # that there are no recipes used in multiple activities, and above I've created activities for any recipes that
    # # aren't used in any activities. So now, go fix up all those ids.
    # to_save = []
    # #to_del = []
    # ActivityIngredient.all.each do |ai|
    #   p ai
    #   recipe = Recipe.find_by_id(ai.activity_id)
    #   if recipe
    #     ai.activity_id = recipe.activities.first.id
    #     #to_del << ai
    #     to_save << ai.clone
    #   end
    # end
    # ActivityIngredient.delete_all
    # #to_del.each do |ai|
    #  # puts "destroying #{ai.inspect}"
    #   #ai.delete
    #   #execute  "DELETE FROM `activity_ingredients` WHERE `activity_ingredients`.`id` = #{ai.id}"
    # #end
    # to_save.each_with_index do |ai, idx|
    #   puts "saving  #{ai.inspect}"
    #   new_ai = ActivityIngredient.new
    #   new_ai.activity_id = ai.activity_id
    #   new_ai.ingredient_id = ai.ingredient_id
    #   new_ai.unit = ai.unit
    #   new_ai.quantity = ai.quantity
    #   new_ai.ingredient_order = ai.ingredient_order
    #   new_ai.display_quantity = ai.display_quantity
    #   new_ai.save
    #   #execute  "UPDATE  `activity_ingredients` SET `activity_id` = #{ai.activity_id} WHERE `activity_ingredients`.`id` = #{idx}"
    # end

  end
end
