class CreateStepIngredients < ActiveRecord::Migration[5.2]
  def change
    create_table :step_ingredients do |t|
      t.integer :step_id, null: false
      t.integer :ingredient_id, null: false
      t.decimal :quantity, null: false
      t.string :unit, null: false

      t.timestamps
    end
    add_index(:step_ingredients, [:step_id, :ingredient_id], unique: true)
  end
end
