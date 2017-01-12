class CreateJouleCookHistoryItems < ActiveRecord::Migration
  def change
    create_table :joule_cook_history_items do |t|
      t.integer :user_id
      t.string :idempotency_id
      t.string :start_time
      t.string :started_from
      t.datetime :deleted_at
      # -- program_attributes --
      t.string :guide_id
      t.string :cook_id
      t.string :timer_id
      t.string :program_id
      t.string :program_type
      t.float :set_point
      t.integer :cook_time
      t.integer :cook_history_item_id
      t.timestamps
    end
    add_index :joule_cook_history_items, [:user_id, :idempotency_id], unique: true
  end
end
