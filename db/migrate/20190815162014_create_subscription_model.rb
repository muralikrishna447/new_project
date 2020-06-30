class CreateSubscriptionModel < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :plan_id
      t.string :status
      t.integer :resource_version, :limit => 8
      t.timestamps
    end

    add_index :subscriptions, :user_id
    add_index :subscriptions, :plan_id
    add_index :subscriptions, [:user_id, :plan_id], unique: true
  end
end
