class AddOrderToRecipeIngredients < ActiveRecord::Migration
  def change
    add_column :recipe_ingredients, :ingredient_order, :integer
  end
end
