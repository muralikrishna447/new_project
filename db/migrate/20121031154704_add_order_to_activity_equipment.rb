class AddOrderToActivityEquipment < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_equipment, :equipment_order, :integer

    add_index :activity_equipment, :equipment_order
  end
end
