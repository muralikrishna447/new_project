class AddDensityToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :density, :decimal
  end
end
