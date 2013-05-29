class AddSourceActivityToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :source_activity_id, :integer
    add_column :activities, :source_type, :integer, :default => 0
  end
end
