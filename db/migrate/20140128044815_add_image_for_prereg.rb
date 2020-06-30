class AddImageForPrereg < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :prereg_image_id, :text
  end
end
