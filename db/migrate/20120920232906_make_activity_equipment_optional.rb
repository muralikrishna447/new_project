class MakeActivityEquipmentOptional < ActiveRecord::Migration[5.2]
  def change
    remove_column :equipment, :optional
    add_column :activity_equipment, :optional, :boolean, default: false
  end
end
