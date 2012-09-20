class MakeQuantityUnitIngredientOptional < ActiveRecord::Migration
  def change
    change_column :step_ingredients, :quantity, :decimal, :null => true
    change_column :step_ingredients, :unit, :string, :null => true
  end
end
