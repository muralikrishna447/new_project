class AddQuantityToActivityIngredients < ActiveRecord::Migration
  def change
    add_column :activity_ingredients, :quantity, :string
  end
end
