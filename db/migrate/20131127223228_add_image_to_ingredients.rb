class AddImageToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :image_id, :text
    add_column :ingredients, :youtube_id, :string
    add_column :ingredients, :text_fields, :text
  end 
end
