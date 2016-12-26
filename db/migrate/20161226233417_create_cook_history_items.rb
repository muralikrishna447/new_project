class CreateCookHistoryItems < ActiveRecord::Migration
  def change
    create_table :cook_history_items do |t|
      t.integer :user_id
      t.string :type
      t.integer :user_content_id

      t.timestamps
    end
  end
end
