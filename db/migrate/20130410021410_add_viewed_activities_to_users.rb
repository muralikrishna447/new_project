class AddViewedActivitiesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :viewed_activities, :text
  end
end
