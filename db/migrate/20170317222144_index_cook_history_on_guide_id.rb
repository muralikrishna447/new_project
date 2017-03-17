class IndexCookHistoryOnGuideId < ActiveRecord::Migration
  def change
    # Have to set name b/c default exceeds 63 chars
    add_index :joule_cook_history_items, [:user_id, :idempotency_id, :guide_id], unique: true, name: 'index_cook_history_on_user_idempotence_guide'
  end
end
