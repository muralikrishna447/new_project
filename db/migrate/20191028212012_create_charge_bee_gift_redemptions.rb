class CreateChargebeeGiftRedemptions < ActiveRecord::Migration
  def change
    create_table :chargebee_gift_redemptions do |t|
      t.string :gift_id
      t.boolean :complete, default: false
      t.integer :user_id
      t.integer :plan_amount
      t.string :currency_code
      t.timestamps
    end

    add_index :chargebee_gift_redemptions, :gift_id
    add_index :chargebee_gift_redemptions, :complete
    add_index :chargebee_gift_redemptions, :gift_id, unique: true
  end
end
