class AddForumMaintenanceToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :forum_maintenance, :boolean
  end
end
