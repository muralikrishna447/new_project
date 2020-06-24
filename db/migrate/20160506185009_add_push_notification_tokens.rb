class AddPushNotificationTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :push_notification_tokens do |t|
      t.integer :actor_address_id
      
      t.string :endpoint_arn, :unique => true
      t.string :device_token
      t.string :app_name

      t.timestamps
    end
    
    add_index :push_notification_tokens, [:endpoint_arn, :actor_address_id], 
      :unique => true, :name => 'aindex_endpoint_and_address'
    add_index :push_notification_tokens, :actor_address_id, :unique => true
  end
end
