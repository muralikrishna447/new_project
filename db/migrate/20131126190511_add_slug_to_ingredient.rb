class AddSlugToIngredient < ActiveRecord::Migration
  def change
    add_column :ingredients, :slug, :string
    add_index :ingredients, :slug
  end
end
