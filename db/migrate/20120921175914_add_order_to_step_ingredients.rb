class AddOrderToStepIngredients < ActiveRecord::Migration
  def change
    add_column :step_ingredients, :ingredient_order, :integer
  end
end
