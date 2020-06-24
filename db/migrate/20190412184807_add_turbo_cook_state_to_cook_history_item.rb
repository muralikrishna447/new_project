class AddTurboCookStateToCookHistoryItem < ActiveRecord::Migration[5.2]
  def change
    add_column :joule_cook_history_items, :turbo_cook_state, :string
  end
end
