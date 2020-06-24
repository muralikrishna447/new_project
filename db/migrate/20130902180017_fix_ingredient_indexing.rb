class FixIngredientIndexing < ActiveRecord::Migration[5.2]
  def up
    # These were useless and creating an unwanted uniqueness constraint
    remove_index(:activity_ingredients, [:activity_id, :ingredient_id])
    remove_index(:step_ingredients, [:step_id, :ingredient_id])

    # These might be useful
    add_index(:activity_ingredients, :activity_id)
    add_index(:activity_ingredients, :ingredient_id)
    add_index(:step_ingredients, :step_id)
    add_index(:step_ingredients, :ingredient_id)
  end

  def down
    add_index(:activity_ingredients, [:activity_id, :ingredient_id], unique: true)
    add_index(:step_ingredients, [:step_id, :ingredient_id], unique: true)
    remove_index(:activity_ingredients, :activity_id)
    remove_index(:activity_ingredients, :ingredient_id)
    remove_index(:step_ingredients, :step_id)
    remove_index(:step_ingredients, :ingredient_id)
  end
end
