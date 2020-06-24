class AddShortDescriptionToAssembly < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :short_description, :text
  end
end
