class AddPreviewCopyToAssemblies < ActiveRecord::Migration
  def change
    add_column :assemblies, :preview_copy, :text
  end
end
