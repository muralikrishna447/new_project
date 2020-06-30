class AddPublicToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :published, :boolean, :default => false
  end
end
