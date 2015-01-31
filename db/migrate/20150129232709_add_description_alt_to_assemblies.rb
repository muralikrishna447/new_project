class AddDescriptionAltToAssemblies < ActiveRecord::Migration
  def change
    add_column :assemblies, :description_alt, :text
  end
end
