class CreateCookHistoryItems < ActiveRecord::Migration
  def change
    create_table :cook_history_items do |t|
      t.integer :user_id
      t.string :history_item_type
      t.string :uuid, :unique => true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
