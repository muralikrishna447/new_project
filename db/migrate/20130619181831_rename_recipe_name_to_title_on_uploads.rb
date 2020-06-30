class RenameRecipeNameToTitleOnUploads < ActiveRecord::Migration[5.2]
  def change
    rename_column :uploads, :recipe_name, :title
  end
end
