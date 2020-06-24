class GiveRecipesAndRecipeStepsIndex < ActiveRecord::Migration[5.2]
  def change
    add_index(:recipes, :activity_id)
    add_index(:steps, :recipe_id)
  end
end
