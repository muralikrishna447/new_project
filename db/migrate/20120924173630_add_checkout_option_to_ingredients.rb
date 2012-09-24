class AddCheckoutOptionToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :for_sale, :boolean, default: false
  end
end
