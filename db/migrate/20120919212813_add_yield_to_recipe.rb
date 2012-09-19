class AddYieldToRecipe < ActiveRecord::Migration
  def change
    add_column :recipes, :yield, :string
  end
end
