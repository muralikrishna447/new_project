class RemoveModeFromComponentAndRenameMetadata < ActiveRecord::Migration[5.2]
  def change
    remove_column :components, :mode
    rename_column :components, :metadata, :meta
  end
end
