class AddImageToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :image_id, :string
    add_column :ingredients, :youtube_id, :string
  end 
end
