class AddSourceActivityToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :source_activity_id, :integer
    add_column :activities, :source_type, :integer, :default => 0
  end
end
