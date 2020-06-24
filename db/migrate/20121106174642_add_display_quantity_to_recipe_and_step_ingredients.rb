class AddDisplayQuantityToRecipeAndStepIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :recipe_ingredients, :display_quantity, :string
    add_column :step_ingredients, :display_quantity, :string
  end
end
