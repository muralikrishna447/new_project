class AddOrderToRecipeIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :recipe_ingredients, :ingredient_order, :integer
  end
end
