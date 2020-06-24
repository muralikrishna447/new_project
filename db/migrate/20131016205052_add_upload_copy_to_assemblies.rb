class AddUploadCopyToAssemblies < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :upload_copy, :text
  end
end
