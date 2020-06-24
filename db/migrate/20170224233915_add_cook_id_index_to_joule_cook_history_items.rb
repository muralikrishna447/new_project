class AddCookIdIndexToJouleCookHistoryItems < ActiveRecord::Migration[5.2]
  def change
    add_index :joule_cook_history_items, :cook_id
  end
end
