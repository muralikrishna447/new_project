class AddSlugToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :slug, :string
    add_index :activities, :slug, unique: true
  end
end
