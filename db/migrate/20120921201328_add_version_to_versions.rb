class AddVersionToVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :version, :string
    add_index :versions, :version
  end
end
