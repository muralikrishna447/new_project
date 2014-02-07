class AddPreregListIdToAssembly < ActiveRecord::Migration
  def change
    add_column :assemblies, :prereg_email_list_id, :string 
  end
end
