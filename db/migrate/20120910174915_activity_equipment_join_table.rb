class ActivityEquipmentJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_equipment do |t|
      t.integer :activity_id, null: false
      t.integer :equipment_id, null: false

      t.timestamps
    end
    add_index(:activity_equipment, [:activity_id, :equipment_id], unique: true, name: 'activity_equipment_index')
  end
end

