class AddForumMaintenanceToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :forum_maintenance, :boolean
  end
end
