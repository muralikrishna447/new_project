class AddLayoutToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :layout_name, :string
  end
end
