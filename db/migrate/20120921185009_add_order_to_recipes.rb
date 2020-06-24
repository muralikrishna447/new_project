class AddOrderToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :recipe_order, :integer

    add_index :recipes, :recipe_order
    add_index :recipe_ingredients, :ingredient_order
    add_index :step_ingredients, :ingredient_order
  end
end
