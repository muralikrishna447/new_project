class CreateGiftingModel < ActiveRecord::Migration[5.2]
  def change
    create_table :gift_certificates do |t|
      t.integer :purchaser_id

      t.string :recipient_email, null: false, default: ""
      t.string :recipient_name, null: false, default: ""
      t.text :recipient_message, default: ""
      t.integer :assembly_id
      t.decimal :price, :precision => 8, :scale => 2, :default => 0
      t.decimal :sales_tax, :precision => 8, :scale => 2, :default => 0
      t.string :token, unique: true
      t.boolean :redeemed, default: false
      t.timestamps
    end
    add_column :enrollments, :gift_certificate_id, :integer
    add_index :gift_certificates, :token
  end
end
