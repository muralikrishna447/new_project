class AddUploadCopyToAssemblies < ActiveRecord::Migration
  def change
    add_column :assemblies, :upload_copy, :text
  end
end
