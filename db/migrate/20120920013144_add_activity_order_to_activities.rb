class AddActivityOrderToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :activity_order, :integer

    add_index :activities, :activity_order
    add_index :steps, :step_order
  end
end
