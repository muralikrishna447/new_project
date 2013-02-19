class AddRecipeStuffToActivity < ActiveRecord::Migration
  def change
    Recipe.all.each do |recipe|
      # create an activity for any recipe that didn't have one so we can move the ingredients and steps over
      if recipe.activities.count == 0
        puts recipe.title
        activity = Activity.create
        activity.title = recipe.title
        activity.yield = recipe.yield
        activity.recipes << recipe
        activity.save!
      end

      activity = recipe.activities.first
      activity.steps = recipe.steps
      activity.save!
    end

    rename_table :recipe_ingredients, :activity_ingredients
    rename_column :activity_ingredients, :recipe_id, :activity_id
    rename_index :activity_ingredients, "index_recipe_ingredients_on_ingredient_order", "index_activity_ingredients_on_ingredient_order"
    rename_index :activity_ingredients, "index_recipe_ingredients_on_recipe_id_and_ingredient_id", "index_activity_ingredients_on_activity_id_and_ingredient_id"

    # The activity_id column in activity_ingredients is actually still pointing to recipe ids. I've verified externally
    # that there are no recipes used in multiple activities, and above I've created activities for any recipes that
    # aren't used in any activities. So now, go fix up all those ids.
    ActivityIngredient.all.each do |ai|
      ai.activity_id = Recipe.find_by_id(ai.activity_id).activities.first.id
    end
  end
end
