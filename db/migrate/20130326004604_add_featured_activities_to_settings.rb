class AddFeaturedActivitiesToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :featured_activity_1_id, :integer
    add_column :settings, :featured_activity_2_id, :integer
    add_column :settings, :featured_activity_3_id, :integer
  end
end
