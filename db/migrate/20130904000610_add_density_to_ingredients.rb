class AddDensityToIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :ingredients, :density, :decimal
  end
end
