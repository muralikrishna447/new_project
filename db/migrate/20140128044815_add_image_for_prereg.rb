class AddImageForPrereg < ActiveRecord::Migration
  def change
    add_column :assemblies, :prereg_image_id, :text
  end
end
