class AddShortDescriptionToAssembly < ActiveRecord::Migration
  def change
    add_column :assemblies, :short_description, :text
  end
end
