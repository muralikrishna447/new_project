class CreateActivityIngredients < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_ingredients do |t|
      t.integer :activity_id, null: false
      t.integer :ingredient_id, null: false

      t.timestamps
    end
    add_index(:activity_ingredients, [:activity_id, :ingredient_id], unique: true)
  end
end
