class RemoveModeFromComponentAndRenameMetadata < ActiveRecord::Migration
  def change
    remove_column :components, :mode
    rename_column :components, :metadata, :meta
  end
end
