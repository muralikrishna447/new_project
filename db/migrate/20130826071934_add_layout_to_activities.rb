class AddLayoutToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :layout_name, :string
  end
end
