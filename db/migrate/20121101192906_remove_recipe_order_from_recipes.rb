class RemoveRecipeOrderFromRecipes < ActiveRecord::Migration[5.2]
  def change
    remove_index :recipes, :column => [:recipe_order]
    remove_column :recipes, :recipe_order
  end
end
