class AddViewedActivitiesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :viewed_activities, :text
  end
end
