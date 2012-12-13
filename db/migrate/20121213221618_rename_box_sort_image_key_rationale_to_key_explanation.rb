class RenameBoxSortImageKeyRationaleToKeyExplanation < ActiveRecord::Migration
  def change
    rename_column :box_sort_images, :key_rationale, :key_explanation
    change_column :box_sort_images, :key_explanation, :text
  end
end
