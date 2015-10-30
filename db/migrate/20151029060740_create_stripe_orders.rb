class CreateStripeOrders < ActiveRecord::Migration
  def change
    create_table :stripe_orders do |t|
      t.string :idempotency_key
      t.integer :user_id
      t.text :data
      t.boolean :submitted, default: false
      t.timestamps
    end
  end
end
