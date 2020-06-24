class RenameActivityIngredientToRecipeIngredient < ActiveRecord::Migration[5.2]
  def change
    remove_index(:activity_ingredients, [:activity_id, :ingredient_id])
    rename_table :activity_ingredients, :recipe_ingredients
    rename_column :recipe_ingredients, :activity_id, :recipe_id
    add_index(:recipe_ingredients, [:recipe_id, :ingredient_id], unique: true)
  end
end
