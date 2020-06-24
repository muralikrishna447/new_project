class AddOrderToStepIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :step_ingredients, :ingredient_order, :integer
  end
end
