class AddPreviewCopyToAssemblies < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :preview_copy, :text
  end
end
