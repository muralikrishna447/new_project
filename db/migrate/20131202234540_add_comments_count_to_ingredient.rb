class AddCommentsCountToIngredient < ActiveRecord::Migration[5.2]
  def change
    add_column :ingredients, :comments_count, :integer, default: 0  
  end
end
