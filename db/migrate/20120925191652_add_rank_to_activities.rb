class AddRankToActivities < ActiveRecord::Migration
  def change
    change_column :activities, :activity_order, :decimal
  end
end
