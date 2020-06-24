class AddQuantityToActivityIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_ingredients, :quantity, :string
  end
end
