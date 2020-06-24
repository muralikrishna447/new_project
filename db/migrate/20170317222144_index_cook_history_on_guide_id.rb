class IndexCookHistoryOnGuideId < ActiveRecord::Migration[5.2]
  def change
    add_index :joule_cook_history_items, [:user_id, :guide_id]
  end
end
