class AddDescriptionAltToAssemblies < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :description_alt, :text
  end
end
