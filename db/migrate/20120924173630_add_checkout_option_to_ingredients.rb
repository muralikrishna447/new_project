class AddCheckoutOptionToIngredients < ActiveRecord::Migration[5.2]
  def change
    add_column :ingredients, :for_sale, :boolean, default: false
  end
end
