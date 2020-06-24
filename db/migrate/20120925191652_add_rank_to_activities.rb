class AddRankToActivities < ActiveRecord::Migration[5.2]
  def change
    change_column :activities, :activity_order, :decimal
  end
end
