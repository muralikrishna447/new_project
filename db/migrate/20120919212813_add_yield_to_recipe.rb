class AddYieldToRecipe < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :yield, :string
  end
end
