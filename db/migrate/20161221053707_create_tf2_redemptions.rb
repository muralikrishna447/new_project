class CreateTf2Redemptions < ActiveRecord::Migration[5.2]
  def change
    create_table :tf2_redemptions do |t|
      t.integer :user_id
      t.string :redemption_code
      t.datetime :redeemed_at
      t.timestamps
    end

    add_index :tf2_redemptions, :redemption_code, unique: true
  end
end
