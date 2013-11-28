class AddImageToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :image_id, :string
  end 
end
