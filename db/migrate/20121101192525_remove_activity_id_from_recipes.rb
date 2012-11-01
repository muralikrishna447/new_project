class RemoveActivityIdFromRecipes < ActiveRecord::Migration
  def change
    remove_index :recipes, :column => [:activity_id]
    remove_column :recipes, :activity_id
  end
end
