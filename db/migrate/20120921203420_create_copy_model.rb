class CreateCopyModel < ActiveRecord::Migration[5.2]
  def change
    create_table :copies do |t|
      t.string :location
      t.text :markdown
      t.timestamps
    end
    add_index :copies, :location
  end
end
