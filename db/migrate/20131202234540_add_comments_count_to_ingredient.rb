class AddCommentsCountToIngredient < ActiveRecord::Migration
  def change
    add_column :ingredients, :comments_count, :integer, default: 0  
  end
end
