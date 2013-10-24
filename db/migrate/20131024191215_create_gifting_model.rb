class CreateGiftingModel < ActiveRecord::Migration
  def change
    create_table :gift_certificates do |t|
      t.integer :purchaser_id
      t.string :recipient_email, :null => false, :default => ""
      t.integer :assembly_id
      t.decimal :price, :precision => 8, :scale => 2, :default => 0
      t.decimal :sales_tax, :precision => 8, :scale => 2, :default => 0
      t.string :token, unique: true
      t.boolean :redeemed
      t.timestamps
    end
    add_index :gift_certificates, :token
  end
end
