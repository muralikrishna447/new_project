class IndexCookHistoryOnGuideId < ActiveRecord::Migration
  def change
    add_index :joule_cook_history_items, [:user_id, :guide_id]
  end
end
