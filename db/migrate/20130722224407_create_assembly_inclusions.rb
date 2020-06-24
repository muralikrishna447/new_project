class CreateAssemblyInclusions < ActiveRecord::Migration[5.2]
  def change
    create_table :assembly_inclusions do |t|
      t.string :includable_type
      t.integer :includable_id
      t.integer :assembly_id
      t.integer :position

      t.timestamps
    end
    add_index :assembly_inclusions, [:includable_id, :includable_type]
    add_index :assembly_inclusions, [:assembly_id]
  end
end
