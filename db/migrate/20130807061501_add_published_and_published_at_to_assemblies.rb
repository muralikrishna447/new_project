class AddPublishedAndPublishedAtToAssemblies < ActiveRecord::Migration
  def change
    add_column :assemblies, :published, :boolean
    add_column :assemblies, :published_at, :datetime
  end
end
