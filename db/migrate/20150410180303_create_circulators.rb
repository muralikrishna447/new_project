class CreateCirculators < ActiveRecord::Migration[5.2]
  def change
    create_table :circulators do |t|
      t.string :serial_number
      t.string :notes
      t.timestamps
    end

    create_table :circulator_users do |t|
      t.belongs_to :user, index: true
      t.belongs_to :circulator, index: true

      t.boolean :owner
    end

    add_index :circulator_users, [:user_id, :circulator_id], :unique => true
  end
end
