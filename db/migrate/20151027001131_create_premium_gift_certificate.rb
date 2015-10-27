class CreatePremiumGiftCertificate < ActiveRecord::Migration
  def change
    create_table :premium_gift_certificates do |t|
      t.integer :purchaser_id
      t.decimal :price, :precision => 8, :scale => 2, :default => 0
      t.decimal :sales_tax, :precision => 8, :scale => 2, :default => 0
      t.string :token, unique: true
      t.boolean :redeemed, default: false
      t.timestamps
    end
    add_index :premium_gift_certificates, :token
  end
end

