class RenameRecipeNameToTitleOnUploads < ActiveRecord::Migration
  def change
    rename_column :uploads, :recipe_name, :title
  end
end
