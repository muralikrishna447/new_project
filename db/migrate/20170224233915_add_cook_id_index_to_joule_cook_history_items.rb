class AddCookIdIndexToJouleCookHistoryItems < ActiveRecord::Migration
  def change
    add_index :joule_cook_history_items, :cook_id
  end
end
