class DeleteRecipes < ActiveRecord::Migration
  def change
    drop_table  :recipes
    drop_table :activity_recipes
    drop_table :activity_recipe_steps
    remove_column :steps, :recipe_id
  end
end
