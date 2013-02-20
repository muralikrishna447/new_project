class AddRecipeStuffToActivity < ActiveRecord::Migration
  def change
    rename_table :recipe_ingredients, :activity_ingredients
    rename_column :activity_ingredients, :recipe_id, :activity_id
    rename_index :activity_ingredients, "index_recipe_ingredients_on_ingredient_order", "index_activity_ingredients_on_ingredient_order"
    rename_index :activity_ingredients, "index_recipe_ingredients_on_recipe_id_and_ingredient_id", "index_activity_ingredients_on_activity_id_and_ingredient_id"

    Recipe.all.each do |recipe|
      # create an activity for any recipe that didn't have one so we can move the ingredients and steps over
      puts recipe.title
      if recipe.activities.count == 0
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

    # The activity_id column in activity_ingredients is actually still pointing to recipe ids. I've verified externally
    # that there are no recipes used in multiple activities, and above I've created activities for any recipes that
    # aren't used in any activities. So now, go fix up all those ids.
    to_save = []
    ActivityIngredient.all.each do |ai|
      recipe = Recipe.find_by_id(ai.activity_id)
      if recipe
        ai.activity_id = recipe.activities.first.id
        to_save << ai
      end
    end
    ActivityIngredient.delete_all
    to_save.each { |ai| ai.save! }
  end
end
