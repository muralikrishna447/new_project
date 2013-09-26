class AddBadgeIdToAssemblies < ActiveRecord::Migration
  def change
    add_column :assemblies, :badge_id, :integer
  end
end
