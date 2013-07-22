class CreateAssemblyInclusions < ActiveRecord::Migration
  def change
    create_table :assembly_inclusions do |t|
      t.string :includable_type
      t.integer :includable_id
      t.integer :assembly_id
      t.integer :position

      t.timestamps
    end
  end
end
