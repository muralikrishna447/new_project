class CreateSubscriptionModel < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :plan_id
      t.string :status
      t.timestamps
    end

    add_index :subscriptions, :user_id
    add_index :subscriptions, :plan_id
  end
end
