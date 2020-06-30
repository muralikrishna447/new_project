class AddBadgeIdToAssemblies < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :badge_id, :integer
  end
end
