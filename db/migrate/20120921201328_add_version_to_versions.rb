class AddVersionToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :version, :string
    add_index :versions, :version
  end
end
