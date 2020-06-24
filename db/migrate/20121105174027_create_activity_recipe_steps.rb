class CreateActivityRecipeSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_recipe_steps do |t|
      t.integer :activity_id, null: false
      t.integer :step_id, null: false
      t.integer :step_order

      t.timestamps
    end
    add_index(:activity_recipe_steps, [:activity_id, :step_id], unique: true)
    add_index(:activity_recipe_steps, :step_order)
  end
end
