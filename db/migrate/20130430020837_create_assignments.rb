class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.integer :activity_id
      t.integer :child_activity_id
      t.timestamps
    end
    add_index :assignments, [:activity_id, :child_activity_id], :name => "index_assignments_on_activity_id_and_child_activity_id"
  end
end
