class AddEventCounterCacheToUsers < ActiveRecord::Migration
  def change
    add_column :users, :events_count, :integer
  end
end
