class CreateEquipment < ActiveRecord::Migration[5.2]
  def change
    create_table :equipment do |t|
      t.string :title
      t.boolean :optional
      t.string :product_url

      t.timestamps
    end
  end
end
