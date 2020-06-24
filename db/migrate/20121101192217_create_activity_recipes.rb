class CreateActivityRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_recipes do |t|
      t.integer :activity_id, null: false
      t.integer :recipe_id, null: false
      t.integer :recipe_order

      t.timestamps
    end
    add_index(:activity_recipes, [:activity_id, :recipe_id], unique: true)
    add_index(:activity_recipes, :recipe_order)
  end
end
