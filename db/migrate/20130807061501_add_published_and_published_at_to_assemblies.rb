class AddPublishedAndPublishedAtToAssemblies < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :published, :boolean
    add_column :assemblies, :published_at, :datetime
  end
end
