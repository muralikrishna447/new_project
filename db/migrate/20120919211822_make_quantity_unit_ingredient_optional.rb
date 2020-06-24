class MakeQuantityUnitIngredientOptional < ActiveRecord::Migration[5.2]
  def change
    change_column :step_ingredients, :quantity, :decimal, :null => true
    change_column :step_ingredients, :unit, :string, :null => true
  end
end
