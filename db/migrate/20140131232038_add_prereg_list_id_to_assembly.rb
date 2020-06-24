class AddPreregListIdToAssembly < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :prereg_email_list_id, :string 
  end
end
